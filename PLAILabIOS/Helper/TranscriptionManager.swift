import OpenAI

class TranscriptionManager {
    private let openAI: OpenAI

    init(apiToken: String) {
        self.openAI = OpenAI(configuration: .init(token: apiToken, timeoutInterval: 700))
    }

    func transcribe(audioData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let query = AudioTranscriptionQuery(
            file: audioData,
            fileType: .m4a,
            model: .whisper_1,
            prompt: "N/A"
        )
        
        openAI.audioTranscriptions(query: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let transcriptionResult):
                    completion(.success(transcriptionResult.text))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
