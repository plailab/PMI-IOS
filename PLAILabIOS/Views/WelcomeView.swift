import SwiftUI
import AVFoundation

struct WelcomeView: View {
    @State private var selection = "Shoulder Raises"
    @State private var name: String = ""
    let exercises = ["Shoulder Raises", "Squats", "Knee Extensions (No)", "Raise Them Knees (No)"]
    let synthesizer = AVSpeechSynthesizer()
    
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
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button("Greet") {
                            configureAudioOutput() // Ensure correct audio routing
                            let utterance = AVSpeechUtterance(string: "Hello \(name)!")
                            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                            synthesizer.speak(utterance)
                        }
                        
                        Picker("Select an exercise", selection: $selection) {
                            ForEach(exercises, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        NavigationLink(destination: CalibrationView(exercise: selection)) {
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
