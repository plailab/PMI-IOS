import SwiftUI
import AVFoundation

struct WelcomeView: View {
    @State private var selection = "Shoulder Raises"
    @State private var name: String = ""
//    let exercises = ["Shoulder Raises", "Leg Raises", "Squats", "Knee Extensions (No)", "Raise Them Knees (No)"]
    // exercises that are playable currently
    let exercises = ["Shoulder Raises", "Leg Raises"]
    let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Simple solid background color
                Color.blue.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    VStack {
                        Text("PLAIful Movement")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("Tap to start playing!")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
//                        TextField("Name", text: $name)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .padding()
//
//                        Button("Greet") {
//                            configureAudioOutput() // Ensure correct audio routing
//                            let utterance = AVSpeechUtterance(string: "Hello \(name)!")
//                            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//                            synthesizer.speak(utterance)
//                        }
                        
                        // Simple exercise display
                        VStack(spacing: 20) {
                            Text(selection)
                                .font(.system(size: 32, weight: .bold))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(8)
                            
                            // Simple shuffle button
                            Button(action: {
                                // Randomly select a different exercise
                                var newSelection: String
                                repeat {
                                    newSelection = exercises.randomElement() ?? selection
                                } while newSelection == selection && exercises.count > 1
                                
                                selection = newSelection
                            }) {
                                HStack {
                                    Image(systemName: "shuffle")
                                        .font(.system(size: 22))
                                    Text("Shuffle Exercise")
                                        .font(.system(size: 22))
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(height: 65)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                        }
                        
                        // Simple start button
                        NavigationLink(destination: BodyPoseDetectionView(exercise: selection)) {
                            Text("Start Exercising")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .frame(height: 65)
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
//                        NavigationLink(destination: RecipeVoiceEntryView(onSubmit: {
//                            // Code to execute when the user submits their voice input
//                            print("Recipe submitted!")
//                            // You might want to save data, navigate back, etc.
//                        })) {
//                            Text("Start Voice")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                                .padding()
//                                .frame(width: 200)
//                                .background(Color.blue)
//                                .cornerRadius(10)
//                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }

    }
}

// Function to configure audio routing
func configureAudioOutput() {
    let audioSession = AVAudioSession.sharedInstance()
    
    do {
        try audioSession.setActive(true)

        // Check if headphones or Bluetooth are connected
        let currentRoute = audioSession.currentRoute
        let headphonesConnected = currentRoute.outputs.contains { output in
            output.portType == .headphones || output.portType == .bluetoothA2DP || output.portType == .bluetoothLE || output.portType == .bluetoothHFP
        }

        if headphonesConnected {
            try audioSession.setCategory(.playback, mode: .default, options: [])
        } else {
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.overrideOutputAudioPort(.speaker)
        }

    } catch {
        print("Error setting up audio session: \(error)")
    }
}

#Preview {
    WelcomeView()
}
