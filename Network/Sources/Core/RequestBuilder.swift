import Foundation

public struct RequestBuilder: Sendable {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func makeRequest<E: Endpoint>(_ endpoint: E) throws(Error) -> URLRequest {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = endpoint.query.isEmpty ? nil : endpoint.query

        guard let url = components?.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        // Headers
        endpoint.headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        // Body
        if endpoint.method.hasBody {
            request.httpBody = endpoint.body
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
        }

        return request
    }
}
