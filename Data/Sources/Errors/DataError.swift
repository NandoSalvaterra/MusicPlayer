import Foundation
import Network

public enum DataError: Error, Sendable, LocalizedError {
    case networkUnavailable
    case invalidData
    case mappingFailed(String)
    case notFound
    case unauthorized
    case serverError(Int)
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network connection unavailable"
        case .invalidData:
            return "Invalid data received from server"
        case .mappingFailed(let details):
            return "Failed to process data: \(details)"
        case .notFound:
            return "Requested content not found"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let code):
            return "Server error (Code: \(code))"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

public extension DataError {
    static func map(from networkError: NetworkError) -> DataError {
        switch networkError {
        case .invalidURL:
            return .invalidData
        case .offline:
            return .networkUnavailable
        case .transport(let urlError):
            return .unknown(urlError)
        case .noResponse:
            return .networkUnavailable
        case .invalidResponse:
            return .invalidData
        case .statusCode(let code, _):
            if code >= 500 {
                return .serverError(code)
            } else if code == 404 {
                return .notFound
            } else if code == 401 || code == 403 {
                return .unauthorized
            } else {
                return .invalidData
            }
        case .decoding(let underlyingError):
            return .mappingFailed("Failed to decode response: \(underlyingError.localizedDescription)")
        case .encoding(let underlyingError):
            return .mappingFailed("Failed to encode request: \(underlyingError.localizedDescription)")
        case .cancelled:
            return .unknown(networkError)
        case .timedOut:
            return .networkUnavailable
        case .unauthorized:
            return .unauthorized
        case .forbidden:
            return .unauthorized
        case .notFound:
            return .notFound
        case .serverError(let code, _):
            return .serverError(code)
        }
    }
}
