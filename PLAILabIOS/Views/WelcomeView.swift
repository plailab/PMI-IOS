import SwiftUI
import AVFoundation
import LiveKit

#if os(iOS) || os(macOS)
import LiveKitKrispNoiseFilter
#endif

// NEXT THINGS TO ADD:
// Add RPC methods for
// Next Exercise
// How many reps

// skipping exercises
// Give instructions if they are not getting the right points (give a small timer)
// Add a function if form is wrong (show a video if it takes too long)

// Non rpc functions
// Introduction video
// add sound effect for each arrow

// look at wii sports, where the thing will make the ooooh when it fails


struct WelcomeView: View {
    @State private var selection = "Shoulder Raises"
    @StateObject private var room = Room() // the server the user is in
    @StateObject private var uiClient = UIUpdateClient() // ui styling (put front end aesthetics changes here)
    @State private var navigateToGame = false
    @State private var name: String = ""
    let exercises = ["Shoulder Raises", "Leg Raises", "Cross Body Reach"]
    
    
    // Krisp is available only on iOS and macOS right now (helps with noise cancellation)
    #if os(iOS) || os(macOS)
    private let krispProcessor = LiveKitKrispNoiseFilter()
    #endif
    
    init() {
        print("WelcomeView initialized")

        #if os(iOS) || os(macOS)
        AudioManager.shared.capturePostProcessingDelegate = krispProcessor
        #endif
    }
    var body: some View {
        NavigationView {
            ZStack {
                uiClient.backgroundColor // Apply background color to fill the screen
                    .edgesIgnoringSafeArea(.all)
                
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
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .foregroundColor(Color.primary)
                        
                        Button(action: {
                            if let currentIndex = exercises.firstIndex(of: selection) {
                                let nextIndex = (currentIndex + 1) % exercises.count
                                selection = exercises[nextIndex]
                                
                                let payload: [String: Any] = [
                                    "current_exercise": selection
                                ]
                                
                                Task{
                                    do {
                                        print("sent the payload")
                                        try await self.sendMessageViaLiveKit(payload, reliable: true)
                                    } catch {
                                        print("Failed to send message: \(error.localizedDescription)")
                                    }
                                }
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
                    
                    Text("Reps per Sets: \(Int(uiClient.reps))")
                        .font(.headline)
                    
                    Slider(
                        value: Binding(
                            get: { Double(uiClient.reps) },
                            set: { uiClient.reps = Int($0) }
                        ),
                        in: 0...24,
                        step: 1
                    )
                    
                    NavigationLink(
                        destination: BodyPoseDetectionView(exercise: selection, repsPerSet: $uiClient.reps),
                        isActive: $navigateToGame
                    ) {
                        EmptyView()
                    }

                    Button(action: {
                        navigateToGame = true
                    }) {
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
                .padding(.horizontal, 20)
                .environmentObject(room)
                .environmentObject(uiClient)
            }
            .onAppear {
                #if os(iOS) || os(macOS)
                room.add(delegate: krispProcessor)
                #endif
                uiClient.connect()
                                
                Task {
                    await registerRpcMethods()

                    while true {
                        do {
                            try await self.sendMessageViaLiveKit(
                                ["all_exercises": exercises, "current_exercise": selection],
                                reliable: true
                            )
                            print("Message sent successfully")
                            break // Exit loop on success
                        } catch {
                            print("Failed to send message: \(error.localizedDescription)")
                            // had to delay because the message might not be received when immediately connected to the server, the dataTrack might not be attatched completely
                            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 sec delay
                        }
                    }
                }
            }
            .onChange(of: uiClient.shouldStartGame) { newValue in
                if newValue {
                    navigateToGame = true
                    uiClient.shouldStartGame = false // reset
                }
            }
            .onChange(of: selection) { newValue in
                Task {
                    do {
                        try await self.sendMessageViaLiveKit(["current_exercise": newValue], reliable: true)
                    } catch {
                        print("Failed to send message: \(error.localizedDescription)")
                    }
                }
            }
           
            .onDisappear {
                uiClient.disconnect()
            }
        }
    }

    func sendMessageViaLiveKit(_ message: [String: Any], reliable: Bool = true) async throws {
        // Convert the message dictionary to Data
        guard let data = try? JSONSerialization.data(withJSONObject: message) else {
            throw NSError(domain: "MessageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize message"])
        }
        
        // Create publish options
        let options = DataPublishOptions(reliable: reliable)
        
        // Publish the data to the room
        try await room.localParticipant.publish(data: data, options: options)
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
        
        await room.localParticipant.registerRpcMethod("start_game") { data in
            print("Voice command received to start game")

            DispatchQueue.main.async {
                self.uiClient.startGameFromCommand()
            }

            return "Game started"
        }
        
        await room.localParticipant.registerRpcMethod("select_exercise") { data in
            print("Received selected exercise data: \(data.payload)")
            
            let message = data.payload
            
            var exercise = ""
            // Extract JSON substring from the message
            if let jsonStartIndex = message.firstIndex(of: "{") {
                let jsonSubstring = message[jsonStartIndex...]
                
                if let jsonData = jsonSubstring.data(using: .utf8) {
                    do {
                        let decoded = try JSONDecoder().decode(ExerciseData.self, from: jsonData)
                        exercise = decoded.exercise
                        print("Exercise:", decoded.exercise)
                    } catch {
                        print("Decoding error:", error)
                    }
                } else {
                    return "Failed to encode JSON substring into Data"
                }
            } else {
                return "No JSON found in message"
            }
            
            navigateToGame = true
            selection = exercise
            return "Exercise \(exercise) selected successfully"
        }
       
        await room.localParticipant.registerRpcMethod("change_reps") { data in
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

            print("Extracted payload for reps: \(payloadString)")

            guard let jsonData = payloadString.data(using: .utf8) else {
                print("Failed to convert to data")
                return "Error: Data conversion failed"
            }
           

            
            do {

                let decoded = try JSONDecoder().decode(RepData.self, from: jsonData)
                let repsString = decoded.reps
                DispatchQueue.main.async {
                    self.uiClient.changeReps(Int(repsString)!) // Update UI background
                }
                print("new rep count: \(uiClient.reps)")

                return "Rep count changed successfully"
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

struct RepData: Codable {
    let reps: String
}

struct ExerciseData: Codable {
    let exercise: String
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
