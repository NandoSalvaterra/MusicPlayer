import AVFoundation
import MediaPlayer
import Data

@Observable
final class GlobalAudioManager: NSObject, @unchecked Sendable {
    
    static let shared = GlobalAudioManager()

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var isSeekInProgress = false

    var isPlaying = false
    var currentTime: Double = 0
    var duration: Double = 0
    var isLoading = false
    var errorMessage: String?
    var currentTrack: Track?

    private override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommands()
        setupNotifications()
    }
    
    deinit {
        cleanup()
    }

    func loadTrack(_ track: Track) {
        guard let previewURL = track.previewURL else {
            errorMessage = "No preview URL available"
            return
        }
        
        currentTrack = track
        cleanup()
        isLoading = true
        errorMessage = nil
        
        let asset = AVURLAsset(url: previewURL)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        setupPlayerItemObservers()
        setupTimeObserver()
        updateNowPlayingInfoSafely()

        if let artworkURL = track.artworkURL {
            let highResURL = getHighResArtworkURL(from: artworkURL)
            loadArtworkAsync(from: highResURL)
        }
        
        Task {
            do {
                let duration = try await asset.load(.duration)
                await MainActor.run {
                    self.duration = CMTimeGetSeconds(duration)
                    self.isLoading = false
                }
                self.updateNowPlayingInfoSafely()
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
        updateNowPlayingInfoSafely()
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlayingInfoSafely()
    }
    
    func seek(to time: Double) {
        guard let player = player, duration > 0 else { return }
        
        isSeekInProgress = true
        let targetTime = CMTime(seconds: min(max(time, 0), duration), preferredTimescale: 600)
        
        player.seek(to: targetTime) { [weak self] _ in
            self?.isSeekInProgress = false
            self?.updateNowPlayingInfoSafely()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)

        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if Thread.isMainThread {
                self.play()
            } else {
                DispatchQueue.main.sync {
                    self.play()
                }
            }
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if Thread.isMainThread {
                self.pause()
            } else {
                DispatchQueue.main.sync {
                    self.pause()
                }
            }
            return .success
        }

        commandCenter.skipForwardCommand.isEnabled = false
        commandCenter.skipBackwardCommand.isEnabled = false
        commandCenter.changePlaybackPositionCommand.isEnabled = false
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAudioSessionInterruption(notification)
        }

        NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleRouteChange(notification)
        }
    }
    
    private func updateNowPlayingInfoSafely() {
        if Thread.isMainThread {
            updateNowPlayingInfoBasic()
        }
    }
    
    private func updateNowPlayingInfoBasic() {
        guard let track = currentTrack else {
            return
        }

        var nowPlayingInfo: [String: Any] = [:]
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist
        
        if let album = track.album {
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        }

        if duration > 0 {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        }

        if let existingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo,
           let artwork = existingInfo[MPMediaItemPropertyArtwork] {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func loadArtworkAsync(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.updateNowPlayingArtwork(image)
                    }
                }
            } catch {

            }
        }
    }
    
    private func updateNowPlayingArtwork(_ image: UIImage) {
        guard var currentInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else {
            return 
        }
        let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 600, height: 600)) { size in
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            image.draw(in: CGRect(origin: .zero, size: size))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resizedImage ?? image
        }
        
        currentInfo[MPMediaItemPropertyArtwork] = artwork
        MPNowPlayingInfoCenter.default().nowPlayingInfo = currentInfo
    }
    
    private func getHighResArtworkURL(from originalURL: URL) -> URL {
        let urlString = originalURL.absoluteString
        let highResString = urlString.replacingOccurrences(of: "100x100", with: "600x600")
        return URL(string: highResString) ?? originalURL
    }
    
    private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            pause()
        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    play()
                }
            }
        @unknown default:
            break
        }
    }
    
    private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            pause()
        default:
            break
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
                self.updateNowPlayingInfoSafely()
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
        updateNowPlayingInfoSafely()
    }
    
    private func cleanup() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        playerItem?.removeObserver(self, forKeyPath: "status")
        
        player?.pause()
        player = nil
        playerItem = nil
        isPlaying = false
        currentTime = 0
        duration = 0
    }
}
