//
//  SpeechService.swift
//  insight
//
//  Created by Petar Petrov on 03/06/2021.
//

import Foundation
import AVFoundation

enum VoiceType: String {
    case undefined
    case standardBg = "bg-bg-Standard-A"
}

class SpeechService: NSObject, AVAudioPlayerDelegate {

    static let shared = SpeechService()
    private(set) var busy: Bool = false
    
    private var player: AVAudioPlayer?
    private var completionHandler: ((Data) -> Void)?
    
    func speak(text: String, voiceType: VoiceType = .standardBg, completion: @escaping (Data?) -> Void) {
        guard !self.busy else {
            print("Speech Service busy!")
            return
        }
        
        self.busy = true
        
        GoogleAPI.postSpeechToText(text, voiceType: voiceType) { [weak self] result in
            switch result {
            case .success(let data):
                completion(data)
                self?.completionHandler = completion
                self?.player = try! AVAudioPlayer(data: data!)
                self?.player?.delegate = self
                self?.player!.play()
            case .failure:
                self?.busy = false
                completion(nil)

            }
        }
    }
    
    // Implement AVAudioPlayerDelegate "did finish" callback to cleanup and notify listener of completion.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player?.delegate = nil
        self.player = nil
        self.busy = false
        
        self.completionHandler = nil
    }
}
