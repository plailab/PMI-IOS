import AVFoundation

protocol AudioRecorderDelegate: AnyObject {
    func didFinishRecording(audioURL: URL)
    func didFailRecording(with error: Error)
}

class AudioRecorderManager: NSObject {
    private var audioRecorder: AVAudioRecorder?
    private let audioFileName = "audioRecording.m4a"
    private let audioFileURL: URL = {
        FileManager.default.temporaryDirectory.appendingPathComponent("audioRecording.m4a")
    }()
    
    weak var delegate: AudioRecorderDelegate?

    func startRecording() throws {
        guard audioRecorder == nil else { throw NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Already recording"]) }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.record()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    func deleteAudio() {
        try? FileManager.default.removeItem(at: audioFileURL)
    }
    
    func getAudioData() -> Data? {
        return try? Data(contentsOf: audioFileURL)
    }
}

extension AudioRecorderManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            delegate?.didFinishRecording(audioURL: recorder.url)
        } else {
            delegate?.didFailRecording(with: NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recording failed."]))
        }
    }
}
