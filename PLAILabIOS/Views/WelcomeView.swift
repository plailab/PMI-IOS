import SwiftUI
import AVFoundation
import LiveKit

#if os(iOS) || os(macOS)
import LiveKitKrispNoiseFilter
#endif

struct WelcomeView: View {
    @State private var selection = "Shoulder Raises"
    @StateObject private var room = Room() // the server the user is in
    @StateObject private var uiClient = UIUpdateClient() // ui styling (put front end aesthetics changes here)
    
    // Krisp is available only on iOS and macOS right now (helps with noise cancellation)
    #if os(iOS) || os(macOS)
    private let krispProcessor = LiveKitKrispNoiseFilter()
    #endif
    
    @State private var name: String = ""
//    let exercises = ["Shoulder Raises", "Leg Raises", "Squats", "Knee Extensions (No)", "Raise Them Knees (No)"]
    // exercises that are playable currently
    let exercises = ["Shoulder Raises", "Leg Raises", "Cross Body Reach"]
    let synthesizer = AVSpeechSynthesizer()
    @State private var repsPerSet: Int = 12  // Parent owns state
    init() {
        print("WelcomeView initialized")

        #if os(iOS) || os(macOS)
        AudioManager.shared.capturePostProcessingDelegate = krispProcessor
        #endif
    }
    var body: some View {
        NavigationView {
            ZStack {
                
                VStack(spacing: 40) {
                    VStack {
                        Text("PLAIful Movement")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("Tap to start playing!")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        
                        VStack(spacing: 20) {
                            Text(selection)
                                .font(.system(size: 32, weight: .bold))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(UIColor.systemBackground)) // Background adapts to light/dark mode
                                .cornerRadius(8)
                                .foregroundColor(Color.primary) // Text color is black in light mode
                            
                            // NOTE: FUNCTION TO PRESS BUTTONS FOR EVERYTHING
                            // Simple shuffle button
                            Button(action: {
                                // Cycle through the exercises
                                if let currentIndex = exercises.firstIndex(of: selection) {
                                    let nextIndex = (currentIndex + 1) % exercises.count
                                    selection = exercises[nextIndex]
                                }
                            }) {
                                HStack {
                                    Image(systemName: "shuffle")
                                        .font(.system(size: 22))
                                    Text("Next Exercise")
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
                        
                        Text("Reps per Sets: \(Int(repsPerSet))")  // Display the slider value
                            .font(.headline)
                        
                        Slider(
                            value: Binding(
                                get: { Double(repsPerSet) },  // Convert Int to Double for the slider
                                set: { repsPerSet = Int($0) } // Convert back to Int when updating
                            ),
                            in: 0...24,
                            step: 1
                        )
                        // Simple start button
                        NavigationLink(destination: BodyPoseDetectionView(exercise: selection, repsPerSet: $repsPerSet)) {
                            Text("Start Exercising")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .frame(height: 65)
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        ControlBar()
                    }
                }
                .padding(.horizontal, 20)
                
                // THERE IS SOME WEIRD VERTICAL PADDING OR IT NEEDS TO FILL
                .environmentObject(room) // Makes sure room is accessible to all child views
                    .environmentObject(uiClient) // Make UIUpdateClient available to child views
                    .background(uiClient.backgroundColor) // Apply global background color
                    .onReceive(uiClient.$backgroundColor) { newColor in
                        print("Background color changed to:", newColor)
                    }
                    .onAppear {
                        #if os(iOS) || os(macOS)
                        room.add(delegate: krispProcessor)
                        #endif
                        print("hi")
                        
                        // Connect to WebSocket server for UI updates
                        uiClient.connect()
                        
                        Task {
                            await registerRpcMethods()
                        }
                    }
                    .onDisappear {
                        // Disconnect when view disappears
                        uiClient.disconnect()
                        print("bye")
                    }
            }
        }

    }
    
    
    
    
    func registerRpcMethods() async {
        // **Background Color Change RPC**
        await room.localParticipant.registerRpcMethod("change_background") { data in
            print("Received background color data: \(data)")

            guard let payloadStart = "\(data)".range(of: "payload: \""),
                  let payloadEnd = "\(data)".range(of: "\", responseTimeout") else {
                print("Failed to locate payload in string")
                return "Error: Payload not found"
            }

            let startIndex = payloadStart.upperBound
            let endIndex = payloadEnd.lowerBound
            let payloadString = String("\(data)"[startIndex..<endIndex])
                .replacingOccurrences(of: "\\\"", with: "\"")
                .replacingOccurrences(of: "\\\\", with: "\\")

            print("Extracted payload for color: \(payloadString)")

            guard let jsonData = payloadString.data(using: .utf8) else {
                print("Failed to convert to data")
                return "Error: Data conversion failed"
            }

            do {
                let colorInfo = try JSONDecoder().decode(ColorData.self, from: jsonData)
                DispatchQueue.main.async {
                    self.uiClient.updateBackgroundColor(colorInfo.color) // Update UI background
                }
                print("Updated background color to: \(colorInfo.color)")
                print("new color: \(uiClient.backgroundColor)")

                return "Background color updated successfully"
            } catch {
                print("JSON decoding error: \(error)")
                return "Error: \(error.localizedDescription)"
            }
        }
    }
}

struct ColorData: Codable {
    let color: String
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
