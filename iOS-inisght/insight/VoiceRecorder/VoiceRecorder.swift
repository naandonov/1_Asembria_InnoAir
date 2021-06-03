//
//  VoiceRecorder.swift
//  insight
//
//  Created by Stoyan Kostov on 3.06.21.
//

import AVFoundation

private enum Constants {
    static let avSampleRateKey = 12000
    static let avNumberOfChannels = 1
}

protocol VoiceRecorderInputProtocol {
    var isPermissionGranted: Bool { get }
    var isRecording: Bool { get }
    func startRecording()
    func stopRecording()
    func requestPermission()
    var voiceData: Data? { get }
}

protocol VoiceRecorderOutputProtocol: AnyObject {
    func didRequestPermission(allowed: Bool)
    func didStartRecording()
    func didFinishRecording(success: Bool)
}

final class VoiceRecorder: NSObject {
    private var recordingSession: AVAudioSession?
    private var audioRecorder: AVAudioRecorder?
    private(set) var isPermissionGranted: Bool = false
    private(set) var isRecording: Bool = false

    private weak var output: VoiceRecorderOutputProtocol?

    init(output: VoiceRecorderOutputProtocol) {
        self.output = output
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

// MARK: - AVAudioRecorderDelegate

extension VoiceRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        output?.didFinishRecording(success: flag)
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        debugPrint(error?.localizedDescription ?? "Recording error occured")
        output?.didFinishRecording(success: false)
    }
}

// MARK: - VoiceRecorderInputProtocol

extension VoiceRecorder: VoiceRecorderInputProtocol {
    func startRecording() {
        guard isPermissionGranted else {
            isRecording = false
            print("Not allowed to record by the user")
            return
        }

        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: Constants.avSampleRateKey,
            AVNumberOfChannelsKey: Constants.avNumberOfChannels,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            output?.didStartRecording()
            isRecording = true
        } catch {
            isRecording = false
            output?.didFinishRecording(success: false)
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
    }

    func requestPermission() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            recordingSession?.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    self?.isPermissionGranted = allowed
                    self?.output?.didRequestPermission(allowed: allowed)
                }
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    var voiceData: Data? {
        let url = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        return try? Data(contentsOf: url)
    }
}
