import Foundation

final class URLSessionClient: HTTPClient {

    private let session: URLSession

    init(configuration: URLSessionConfiguration = .default) {
        configuration.waitsForConnectivity = true
        self.session = URLSession(configuration: configuration)
    }

    func send<T: Decodable & Sendable>(_ request: URLRequest, decoder: JSONDecoder) async throws(Error) -> T {
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
            throw NetworkError.map(error)
        }
    }
}
