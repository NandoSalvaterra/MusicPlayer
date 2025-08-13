import AVFoundation
import Foundation

@Observable
final class AudioPlayerManager: NSObject, @unchecked Sendable {

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var isSeekInProgress = false

    var isPlaying = false
    var currentTime: Double = 0
    var duration: Double = 0
    var isLoading = false
    var errorMessage: String?

    override init() {
        super.init()
        setupAudioSession()
    }
    
    deinit {
        cleanup()
    }

    func loadTrack(url: URL) {
        cleanup()
        isLoading = true
        errorMessage = nil
        
        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        setupPlayerItemObservers()
        setupTimeObserver()

        Task {
            do {
                let duration = try await asset.load(.duration)
                await MainActor.run {
                    self.duration = CMTimeGetSeconds(duration)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load track: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: Double) {
        guard let player = player, duration > 0 else { return }
        
        isSeekInProgress = true
        let targetTime = CMTime(seconds: min(max(time, 0), duration), preferredTimescale: 600)
        
        player.seek(to: targetTime) { [weak self] _ in
            self?.isSeekInProgress = false
        }
    }
    
    // MARK: - Private Methods

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            errorMessage = "Failed to setup audio session: \(error.localizedDescription)"
        }
    }
    
    private func setupPlayerItemObservers() {
        guard let playerItem = playerItem else { return }

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.handleTrackEndReached()
        }

        playerItem.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status", let playerItem = object as? AVPlayerItem {
            DispatchQueue.main.async { [weak self] in
                switch playerItem.status {
                case .readyToPlay:
                    self?.isLoading = false
                case .failed:
                    self?.errorMessage = playerItem.error?.localizedDescription ?? "Playback failed"
                    self?.isLoading = false
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func setupTimeObserver() {
        guard let player = player else { return }
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, !self.isSeekInProgress else { return }
            
            let seconds = CMTimeGetSeconds(time)
            if seconds.isFinite {
                self.currentTime = seconds
            }
            
            if let playerItem = self.playerItem, 
               seconds >= CMTimeGetSeconds(playerItem.duration) - 0.1 {
                self.isPlaying = false
            }
        }
    }
    
    private func handleTrackEndReached() {
        isPlaying = false
        currentTime = 0
        seek(to: 0)
    }
    
    private func cleanup() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }

        playerItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
        
        player?.pause()
        player = nil
        playerItem = nil
        isPlaying = false
        currentTime = 0
        duration = 0
    }
}
