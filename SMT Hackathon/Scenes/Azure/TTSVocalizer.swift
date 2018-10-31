import Foundation
import AVFoundation

final class TTSVocalizer: NSObject, AVAudioPlayerDelegate {
    
    static let sharedInstance = TTSVocalizer()
    
    private let synthesizer = TTSSynthesizer()
    
    private var player: AVAudioPlayer?
        
    private override init() {}

    func vocalize(_ text: String) {
        try? AVAudioSession.sharedInstance().setMode(.spokenAudio)
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        try? AVAudioSession.sharedInstance().setActive(true)
        self.synthesizer.synthesize(text: text) { [weak self] (data: Data) in
            guard let player = try? AVAudioPlayer(data: data) else { return }
            player.delegate = self
            self?.player = player            
            self?.player?.prepareToPlay()
            self?.player?.play()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
    }
    
}
