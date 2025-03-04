import SwiftUICore
import SwiftUI


// https://platform.openai.com/docs/guides/realtime
// https://www.youtube.com/watch?v=eWsvwTnscBA
// I could possibly do a webserver in cloudflare or I can just call it directly
// If I do in cloudflare there will probably be more support,
// but if I do it that way, it just adds an extra layer of complexity


// If we go with realtime api, i imagine it taking a week to set up. (and a lot longer for actual good integration)
// it seems really interesting though because it supports function calling
// which means if the user wants to change the color or the exercise, they could probably
// ask for a list (using a getter function), then say change exercise (setter function) to one from the list

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
