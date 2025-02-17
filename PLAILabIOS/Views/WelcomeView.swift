import SwiftUI
import AVFoundation

struct WelcomeView: View {
    @State private var selection = "Shoulder Raises"
    @State private var name : String = ""
    let exercises = ["Shoulder Raises", "Squats", "Knee Extensions (No)", "Raise Them Knees (No)"]
    let synthesizer = AVSpeechSynthesizer();
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.blue.opacity(0.2).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    VStack {
                        Text("PLAIful Movement")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Tap to start playing!")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        TextField("Name", text: $name)
                            .padding()
                        
                        
                        Button("Greet"){
                            let utterance = AVSpeechUtterance(string: "Hello \(name)!")
                            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                            AVSpeechSynthesizer().speak(utterance)
                        }
                        
                        
                        Picker("Select an exercise", selection: $selection) {
                            ForEach(exercises, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        NavigationLink(destination: BodyPoseDetectionView(exercise:selection)) {
                            Text("Start Detection")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}
#Preview {
    WelcomeView()
}
