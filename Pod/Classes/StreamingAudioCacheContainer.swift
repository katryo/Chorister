//
//  StreamingAudioCacheContainer.swift
//  Pods
//
//  Created by RYOKATO on 2015/12/05.
//
//

import AVFoundation

var context = "playAudioContext"

open class StreamingAudioCacheContainer: NSObject {
    var musicPlayer: AVPlayer = AVPlayer()
    var musicPlayerItems = [AVPlayerItem]()
    var isLooping: Bool
    var audioLoader: AudioLoader
    var audioCache: Cache<NSData>
    
    public init (repeats: Bool) {
        audioCache = Cache(name: "audioCache")
        self.isLooping = repeats
        audioLoader = AudioLoader(cache: audioCache)
        super.init()
    }
    
    deinit {
        for item in musicPlayerItems {
            item.removeObserver(self, forKeyPath: "status")
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    public func reset() {
        audioCache.removeAllObjects()
        audioLoader = AudioLoader(cache: audioCache)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if musicPlayer.currentItem!.status == AVPlayerItem.Status.readyToPlay {
            if keyPath == "status" {
                musicPlayer.play()
                if isLooping {
                    NotificationCenter.default.addObserver(self, selector: "musicFinished", name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: musicPlayer.currentItem)

                }

            }
        }
    }
    
    func musicFinished() {
        musicPlayer.seek(to: CMTimeMake(value: 0, timescale: 600))
        musicPlayer.play()
    }
    
    public func changeAudio(url: NSURL) {
        let asset = loadAssetFromCacheOrWeb(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.musicPlayer.replaceCurrentItem(with: playerItem)
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: &context)
        musicPlayerItems.append(playerItem)
    }
    
    public func pauseAudio() {
        musicPlayer.pause()
    }
    
    private func loadAssetFromCacheOrWeb(url: NSURL) -> AVURLAsset {
        let urlString = url.absoluteString
        var asset: AVURLAsset
        if (audioCache.objectForKey(key: urlString!) != nil) {
            print("Audio resource \(url) found in audioCache.")
            let path = audioCache.pathForKey(key: urlString!)
            print("path is ", path)
            let filePathURL = NSURL.fileURL(withPath: path)
            asset = AVURLAsset(url: filePathURL, options: nil)
        } else {
            print("Audio resource \(url) not found in audioCache.")
            let scheme = url.scheme
            asset = AVURLAsset(url: urlWithCustomScheme(url: url, scheme: scheme! + "streaming") as URL, options: nil)
        }
        asset.resourceLoader.setDelegate(audioLoader, queue: DispatchQueue.main)
        return asset
    }
    
    private func urlWithCustomScheme(url: NSURL, scheme: String) -> NSURL {
        let components = NSURLComponents(url: url as URL, resolvingAgainstBaseURL: false)!
        components.scheme = scheme
        return components.url! as NSURL
    }
}

