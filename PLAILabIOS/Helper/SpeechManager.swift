import AVFoundation
import OpenAI
import Combine


class SpeechManager: ObservableObject {
    private let audioRecorder: AudioRecorderManager
    private let transcriptionManager: TranscriptionManager
    
    @Published var state: RecorderState = .idle
    @Published var transcription: String?
    @Published var errorMessage: String?

    init(audioRecorder: AudioRecorderManager, transcriptionManager: TranscriptionManager) {
        self.audioRecorder = audioRecorder
        self.transcriptionManager = transcriptionManager
        self.audioRecorder.delegate = self
    }

    // Switch voice state to recording and activate audio manager
    func startRecording() {
        do {
            try audioRecorder.startRecording()
            state = .recording
        } catch {
            handleError(error)
        }
    }

    func stopRecording() {
        audioRecorder.stopRecording()
        state = .processing
    }

    // Once voice is stored in dedicated file we need to terminate the audio session
    func processRecording() {
        guard let audioData = audioRecorder.getAudioData() else {
            handleError(NSError(domain: "SpeechManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Audio data not available"]))
            return
        }

        transcriptionManager.transcribe(audioData: audioData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let text):
                    self?.transcription = text
                    self?.state = .idle
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }

        audioRecorder.deleteAudio()
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        state = .error(error)  // Pass the error here
    }

}

extension SpeechManager: AudioRecorderDelegate {
    func didFinishRecording(audioURL: URL) {
        processRecording()
    }
    
    func didFailRecording(with error: Error) {
        handleError(error)
    }
}
