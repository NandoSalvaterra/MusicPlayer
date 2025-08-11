import Foundation

public enum HTTPMethod: String, Sendable {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case head    = "HEAD"

    var hasBody: Bool {
        switch self {
        case .post, .put, .patch: return true
        default: return false
        }
    }
}
