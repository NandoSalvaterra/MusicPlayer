import Foundation

public final class URLSessionClient: HTTPClient {

    private let session: URLSession
    private let networkMonitor: NetworkMonitorProtocol

    public init(
        configuration: URLSessionConfiguration = .default,
        networkMonitor: NetworkMonitorProtocol = NetworkMonitor()
    ) {
        configuration.waitsForConnectivity = true
        self.session = URLSession(configuration: configuration)
        self.networkMonitor = networkMonitor
        self.networkMonitor.startMonitoring()
    }

    public func send<T: Decodable & Sendable>(_ request: URLRequest, decoder: JSONDecoder) async throws(Error) -> T {
        guard networkMonitor.isConnected else {
            throw NetworkError.offline
        }
        
        do {
            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(http.statusCode) else {
                throw NetworkError.mapStatus(http.statusCode, data: data)
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decoding(underlying: error)
            }
        } catch {
            if error is NetworkError {
                throw error
            }
            throw NetworkError.map(error)
        }
    }
    
    deinit {
        networkMonitor.stopMonitoring()
    }
}
