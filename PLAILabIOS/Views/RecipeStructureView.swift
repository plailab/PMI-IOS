


struct RecipeVoiceEntryView: View {
    @StateObject var speechManager = SpeechManager(audioRecorder: AudioRecorderManager(), transcriptionManager: TranscriptionManager(apiToken: "YOUR_API_TOKEN")) // OPEN AI API token
    @State private var isRecording = false
    var onSubmit: () -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Describe Your Thoughts")
                    .font(.system(.title2, weight: .bold))
                
                if !speechManager.transcription.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(speechManager.transcription)
                            .font(.system(.subheadline, weight: .regular))
                            .multilineTextAlignment(.leading)
                    }
                    .padding(10)
                    .frameWidth(.infiniteWidth, alignment: .leading)
                    .background(Color.surfaceGray)
                    .cornerRadius(4)
                    .transition(.move(edge: .bottom).combined(with: .opacity)) // Transition effect
                    .animation(.easeInOut, value: speechManager.transcription)
                }
            }
            .padding([.horizontal, .top], 16)
        }
        .safeAreaInset(edge: .bottom) {
            SpeechRecorderView(speechManager: speechManager) {
                onSubmit()
            }
            .padding(16)
        }
    }
}

