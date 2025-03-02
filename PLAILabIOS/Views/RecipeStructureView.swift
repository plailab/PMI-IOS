import SwiftUICore
import SwiftUI

struct RecipeVoiceEntryView: View {
    @StateObject var speechManager = SpeechManager(audioRecorder: AudioRecorderManager(), transcriptionManager: TranscriptionManager(apiToken: getApiKey() ?? "Bruh"))
    @State private var isRecording = false
    var onSubmit: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Describe Your Thoughts")
                    .font(.system(.title2, weight: .bold))
                
                if let transcription = speechManager.transcription, !transcription.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(transcription)
                            .font(.system(.subheadline, weight: .regular))
                            .multilineTextAlignment(.leading)
                    }
//                    .padding(10)
//                    .frameWidth(.infiniteWidth, alignment: .leading)
//                    .background(Color.surfaceGray)
//                    .cornerRadius(4)
//                    .transition(.move(edge: .bottom).combined(with: .opacity))
//                    .animation(.easeInOut, value: speechManager.transcription)
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

func getApiKey() -> String? {
    print("am i not allowed to print?")
    if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
       let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
        print(dict)
        return dict["OpenAIKey"] as? String
    }
    return nil
}
