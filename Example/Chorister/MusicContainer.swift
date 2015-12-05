import Chorister

class MusicContainer: StreamingAudioCacheContainer {
    static let sharedInstance = MusicContainer(repeats: true)
    override init(repeats: Bool) {
        super.init(repeats: repeats)
    }
}
