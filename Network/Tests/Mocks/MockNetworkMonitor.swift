import Foundation
@testable import Network

final class MockNetworkMonitor: NetworkMonitorProtocol, @unchecked Sendable {
    
    var isConnected: Bool
    var connectionType: ConnectionType
    
    private(set) var startMonitoringCallCount = 0
    private(set) var stopMonitoringCallCount = 0
    private(set) var startMonitoringCalled = false
    private(set) var stopMonitoringCalled = false
    
    init(isConnected: Bool = true, connectionType: ConnectionType = .wifi) {
        self.isConnected = isConnected
        self.connectionType = connectionType
    }
    
    func startMonitoring() {
        startMonitoringCalled = true
        startMonitoringCallCount += 1
    }
    
    func stopMonitoring() {
        stopMonitoringCalled = true
        stopMonitoringCallCount += 1
    }

    func reset() {
        startMonitoringCallCount = 0
        stopMonitoringCallCount = 0
        startMonitoringCalled = false
        stopMonitoringCalled = false
    }

    func simulateOffline() {
        isConnected = false
        connectionType = .none
    }

    func simulateOnline(connectionType: ConnectionType = .wifi) {
        isConnected = true
        self.connectionType = connectionType
    }
    
    func simulateConnectionTypeChange(to newType: ConnectionType) {
        connectionType = newType
        isConnected = newType != .none
    }
}
