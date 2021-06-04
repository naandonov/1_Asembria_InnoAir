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

final class SpeechService: NSObject, AVAudioPlayerDelegate {

    static let shared = SpeechService()
    private(set) var busy: Bool = false
    
    private var player: AVAudioPlayer?
    private var completionHandler: ((Data) -> Void)?
    
    func text(voiceData: Data, voiceType: VoiceType = .standardBg, completion: @escaping (SpeechRecognition?) -> Void) {
        GoogleAPI.postSpeechToText(voiceData: voiceData,
                                   voiceType: voiceType,
                                   completion: { result in
                                    switch result {
                                    case .success(let value):
                                        completion(value.results.first)
                                    case .failure:
                                        completion(nil)
                                    }
                                   })
    }
    
    func speak(text: String, voiceType: VoiceType = .standardBg, completion: @escaping (Data?) -> Void) {
        guard !self.busy else {
            print("Speech Service busy!")
            return
        }
        
        self.busy = true
        
        GoogleAPI.postTextToSpeech(text, voiceType: voiceType) { [weak self] result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure:
                self?.busy = false
                completion(nil)
            }
        }
    }
    
    func play(_ data: Data) {
//        self?.completionHandler = completion
        player = try? AVAudioPlayer(data: data)
        player?.delegate = self
        player?.play()
    }
    
    // Implement AVAudioPlayerDelegate "did finish" callback to cleanup and notify listener of completion.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player?.delegate = nil
        self.player = nil
        self.busy = false
        
        self.completionHandler = nil
    }
}

extension SpeechService {
    func store(audioData: Data?, name: String) {
        let fileManager = FileManager.default
        let soundsDirectoryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Sounds")

        //attempt to create the folder
        do {
            try fileManager.createDirectory(atPath: soundsDirectoryURL.path,
                                            withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        let sounFileURL = soundsDirectoryURL.appendingPathComponent("\(name).aiff")
        try? audioData?.write(to: sounFileURL)
    }
}
