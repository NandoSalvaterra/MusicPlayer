import Foundation
import SystemConfiguration

public protocol NetworkMonitorProtocol: Sendable {
    var isConnected: Bool { get }
    var connectionType: ConnectionType { get }
    
    func startMonitoring()
    func stopMonitoring()
}

public enum ConnectionType: Sendable {
    case wifi
    case cellular
    case ethernet
    case unknown
    case none
}

public final class NetworkMonitor: NetworkMonitorProtocol, @unchecked Sendable {
    private let reachability: SCNetworkReachability?
    private let queue = DispatchQueue(label: "NetworkMonitor", qos: .utility)
    
    private var _isConnected = false
    private var _connectionType = ConnectionType.unknown
    private let lock = NSLock()
    
    public var isConnected: Bool {
        lock.withLock { _isConnected }
    }
    
    public var connectionType: ConnectionType {
        lock.withLock { _connectionType }
    }
    
    public init() {
        self.reachability = Self.createReachability()
        checkInitialStatus()
    }

    deinit {
        stopMonitoring()
    }

    private static func createReachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        return withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
            }
        }
    }


    private func checkInitialStatus() {
        guard let reachability = reachability else { return }
        
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachability, &flags) {
            updateConnectionStatus(flags: flags)
        }
    }
    
    public func startMonitoring() {
        guard let reachability = reachability else { return }
        
        var context = SCNetworkReachabilityContext(
            version: 0,
            info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        
        let callback: SCNetworkReachabilityCallBack = { _, flags, info in
            guard let info = info else { return }
            let monitor = Unmanaged<NetworkMonitor>.fromOpaque(info).takeUnretainedValue()
            monitor.updateConnectionStatus(flags: flags)
        }
        
        if SCNetworkReachabilitySetCallback(reachability, callback, &context) {
            SCNetworkReachabilitySetDispatchQueue(reachability, queue)
        }
    }
    
    public func stopMonitoring() {
        guard let reachability = reachability else { return }
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }
    
    private func updateConnectionStatus(flags: SCNetworkReachabilityFlags) {
        let newConnected = isNetworkReachable(flags: flags)
        let newType = determineConnectionType(flags: flags)
        
        let (wasConnected, typeChanged) = lock.withLock {
            let wasConnected = _isConnected != newConnected
            let typeChanged = _connectionType != newType
            
            _isConnected = newConnected
            _connectionType = newType
            
            return (wasConnected, typeChanged)
        }
    }
    
    private func isNetworkReachable(flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
    
    private func determineConnectionType(flags: SCNetworkReachabilityFlags) -> ConnectionType {
        guard isNetworkReachable(flags: flags) else { return .none }
        
        if flags.contains(.isWWAN) {
            return .cellular
        } else if flags.contains(.reachable) {
            return .wifi
        } else {
            return .unknown
        }
    }
}
