//
//  StreamingAudioCacheContainer.swift
//  Pods
//
//  Created by RYOKATO on 2015/12/05.
//
//

import AVFoundation
import AwesomeCache

var context = "playAudioContext"

public class StreamingAudioCacheContainer: NSObject {
    var musicPlayer: AVPlayer = AVPlayer()
    var musicPlayerItems = [AVPlayerItem]()
    var isLooping: Bool
    var audioLoader: AudioLoader
    var audioCache = SlashAcceptableCache?()
    
    public init (repeats: Bool) {
        var audioCacheBody = Cache<NSData>?()
        do {
            audioCacheBody = try Cache<NSData>(name: "audio")
        } catch _ {
            print("Failed to initialize audioCache")
        }
        audioCache = SlashAcceptableCache(cache: audioCacheBody!)
        self.isLooping = repeats
        audioLoader = AudioLoader(cache: audioCache!)
        super.init()
    }
    
    deinit {
        for item in musicPlayerItems {
            item.removeObserver(self, forKeyPath: "status")
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public func reset() {
        audioCache!.removeAllObjects()
        audioLoader = AudioLoader(cache: audioCache!)
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if musicPlayer.currentItem!.status == AVPlayerItemStatus.ReadyToPlay {
            if keyPath == "status" {
                musicPlayer.play()
                if isLooping {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "musicFinished", name: AVPlayerItemDidPlayToEndTimeNotification, object: musicPlayer.currentItem)
                    
                }
                
            }
        }
    }
    
    func musicFinished() {
        musicPlayer.seekToTime(CMTimeMake(0, 600))
        musicPlayer.play()
    }
    
    
    public func changeAudio(url: NSURL) {
        let asset = loadAssetFromCacheOrWeb(url)
        let playerItem = AVPlayerItem(asset: asset)
        musicPlayer.replaceCurrentItemWithPlayerItem(playerItem)
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: &context)
        musicPlayerItems.append(playerItem)
    }
    
    public func pauseAudio() {
        musicPlayer.pause()
    }
    
    private func loadAssetFromCacheOrWeb(url: NSURL) -> AVURLAsset {
        let urlString = url.absoluteString
        var asset: AVURLAsset
        if (audioCache?.objectForKey(urlString) != nil) {
            let path = audioCache!.pathForKey(urlString)
            let filePathURL = NSURL.fileURLWithPath(path)
            asset = AVURLAsset(URL: filePathURL, options: nil)
        } else {
            print("Audio resource \(url) not found in audioCache.")
            asset = AVURLAsset(URL: url, options: nil)
        }
        asset.resourceLoader.setDelegate(audioLoader, queue: dispatch_get_main_queue())
        return asset
    }
    
    private func URLWithCustomScheme(url: NSURL, scheme: String) -> NSURL {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!
        components.scheme = scheme
        return components.URL!
    }
}

