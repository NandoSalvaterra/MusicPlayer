import Foundation

public enum NetworkError: Error, Sendable {
    case invalidURL
    case offline
    case transport(URLError)
    case noResponse
    case invalidResponse
    case statusCode(Int, Data?)
    case decoding(underlying: Error)
    case encoding(underlying: Error)
    case cancelled
    case timedOut
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int, Data?)
}

// MARK: - Maping Extension
extension NetworkError {

    static func map(_ error: Error) -> NetworkError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .cancelled: return .cancelled
            case .timedOut:  return .timedOut
            default:         return .transport(urlError)
            }
        }
        return .transport(URLError(.unknown))
    }

    static func mapStatus(_ status: Int, data: Data?) -> NetworkError {
        switch status {
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 500...599: return .serverError(status, data)
        default: return .statusCode(status, data)
        }
    }
}
