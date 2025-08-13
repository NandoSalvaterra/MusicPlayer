import XCTest
@testable import Data
@testable import Network

final class MusicRepositoryTests: XCTestCase {
    private var repository: MusicRepository!
    private var mockHTTPClient: MockHTTPClient!
    
    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        repository = MusicRepository(
            httpClient: mockHTTPClient,
            baseURL: URL(string: "https://itunes.apple.com/")!
        )
    }
    
    override func tearDown() {
        repository = nil
        mockHTTPClient = nil
        super.tearDown()
    }
    
    func testSearchTracksSuccess() async throws {
        let mockResponse = TestDataFactory.createMixedSearchResults()
        mockHTTPClient.setResponse(for: "/search", response: mockResponse)
        
        let result = try await repository.searchTracks(query: "test", limit: 10, offset: 0)
        
        XCTAssertEqual(result.tracks.count, 2)
        XCTAssertEqual(result.albums.count, 2)
        XCTAssertEqual(result.totalCount, 4)
        XCTAssertFalse(result.hasMoreResults)
        
        XCTAssertEqual(mockHTTPClient.sendCallCount, 1)
        let request = mockHTTPClient.lastRequest()
        XCTAssertEqual(request?.url?.path, "/search")
        XCTAssertTrue(request?.url?.query?.contains("term=test") ?? false)
        XCTAssertTrue(request?.url?.query?.contains("limit=10") ?? false)
        XCTAssertTrue(request?.url?.query?.contains("offset=0") ?? false)
    }
    
    func testSearchTracksWithPagination() async throws {
        let mockResponse = TestDataFactory.createSearchResponse(
            tracks: [TestDataFactory.createTrackDTO()]
        )
        mockHTTPClient.setResponse(for: "/search", response: mockResponse)
        
        _ = try await repository.searchTracks(query: "artist", limit: 25, offset: 50)
        
        let request = mockHTTPClient.lastRequest()
        XCTAssertTrue(request?.url?.query?.contains("limit=25") ?? false)
        XCTAssertTrue(request?.url?.query?.contains("offset=50") ?? false)
    }
    
    func testSearchTracksNetworkOffline() async {
        mockHTTPClient.setError(for: "/search", error: NetworkError.offline)
        
        do {
            _ = try await repository.searchTracks(query: "test", limit: 10, offset: 0)
            XCTFail("Expected error to be thrown")
        } catch {
            guard case DataError.networkUnavailable = error else {
                XCTFail("Expected DataError.networkUnavailable, got \(error)")
                return
            }
        }
    }
    
    func testSearchTracksServerError() async {
        mockHTTPClient.setError(for: "/search", error: NetworkError.serverError(500, nil))
        
        do {
            _ = try await repository.searchTracks(query: "test", limit: 10, offset: 0)
            XCTFail("Expected error to be thrown")
        } catch {
            guard case DataError.serverError(let code) = error else {
                XCTFail("Expected DataError.serverError, got \(error)")
                return
            }
            XCTAssertEqual(code, 500)
        }
    }
    
    func testSearchTracksDecodingError() async {
        let decodingError = DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: [], debugDescription: "Invalid JSON")
        )
        mockHTTPClient.setError(for: "/search", error: NetworkError.decoding(underlying: decodingError))
        
        do {
            _ = try await repository.searchTracks(query: "test", limit: 10, offset: 0)
            XCTFail("Expected error to be thrown")
        } catch {
            guard case DataError.mappingFailed(let message) = error else {
                XCTFail("Expected DataError.mappingFailed, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("Failed to decode response"))
        }
    }
    
    func testGetAlbumTracksSuccess() async throws {
        let albumDTO = TestDataFactory.createAlbumDTO()
        let tracks = [
            TestDataFactory.createTrackDTO(id: 1, name: "Song 1", trackNumber: 1),
            TestDataFactory.createTrackDTO(id: 2, name: "Song 2", trackNumber: 2),
            TestDataFactory.createTrackDTO(id: 3, name: "Song 3", trackNumber: 3)
        ]
        let mockResponse = TestDataFactory.createAlbumTracksResponse(
            albumDTO: albumDTO,
            tracks: tracks
        )
        mockHTTPClient.setResponse(for: "/lookup", response: mockResponse)
        
        let result = try await repository.getAlbumTracks(albumId: 456)
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].title, "Song 1")
        XCTAssertEqual(result[0].trackNumber, 1)
        XCTAssertEqual(result[1].title, "Song 2")
        XCTAssertEqual(result[1].trackNumber, 2)
        
        XCTAssertEqual(mockHTTPClient.sendCallCount, 1)
        let request = mockHTTPClient.lastRequest()
        XCTAssertEqual(request?.url?.path, "/lookup")
        XCTAssertTrue(request?.url?.query?.contains("id=456") ?? false)
        XCTAssertTrue(request?.url?.query?.contains("entity=song") ?? false)
    }
    
    func testGetAlbumTracksFiltersOutAlbumInfo() async throws {
        let albumDTO = TestDataFactory.createAlbumDTO()
        let tracks = [TestDataFactory.createTrackDTO()]
        let mockResponse = TestDataFactory.createAlbumTracksResponse(
            albumDTO: albumDTO,
            tracks: tracks
        )
        mockHTTPClient.setResponse(for: "/lookup", response: mockResponse)
        
        let result = try await repository.getAlbumTracks(albumId: 456)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].title, "Test Song")
    }
    
    func testGetAlbumTracksNotFound() async {
        mockHTTPClient.setError(for: "/lookup", error: NetworkError.notFound)
        
        do {
            _ = try await repository.getAlbumTracks(albumId: 999)
            XCTFail("Expected error to be thrown")
        } catch {
            guard case DataError.notFound = error else {
                XCTFail("Expected DataError.notFound, got \(error)")
                return
            }
        }
    }
    
    func testGetAlbumTracksEmptyResponse() async throws {
        let emptyResponse = TestDataFactory.createAlbumTracksResponse(tracks: [])
        mockHTTPClient.setResponse(for: "/lookup", response: emptyResponse)
        
        let result = try await repository.getAlbumTracks(albumId: 456)
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func testSearchTracksEmptyResponse() async throws {
        let emptyResponse = TestDataFactory.createSearchResponse()
        mockHTTPClient.setResponse(for: "/search", response: emptyResponse)
        
        let result = try await repository.searchTracks(query: "nonexistent", limit: 10, offset: 0)
        
        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(result.totalCount, 0)
    }
    
    func testRepositoryHandlesGenericError() async {
        let genericError = NSError(domain: "TestError", code: 999, userInfo: nil)
        mockHTTPClient.setError(for: "/search", error: genericError)
        
        do {
            _ = try await repository.searchTracks(query: "test", limit: 10, offset: 0)
            XCTFail("Expected error to be thrown")
        } catch {
            guard case DataError.unknown(let underlyingError) = error else {
                XCTFail("Expected DataError.unknown, got \(error)")
                return
            }
            XCTAssertEqual((underlyingError as NSError).code, 999)
        }
    }
}
