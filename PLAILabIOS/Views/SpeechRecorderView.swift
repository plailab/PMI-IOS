import SwiftUI

struct SpeechRecorderView: View {
    @ObservedObject var speechManager: SpeechManager
    var onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Recording controls
            HStack {
                // Recording button
                Button(action: handleRecordButton) {
                    ZStack {
                        Circle()
                            .fill(buttonColor)
                            .frame(width: 60, height: 60)
                        
                        Icon
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    }
                    .shadow(radius: 3)
                }
                
                // Status and instructions
                VStack(alignment: .leading, spacing: 4) {
                    Text(statusText)
                        .font(.headline)
                    
                    Text(instructionText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 12)
                
                Spacer()
                
                // Submit button (only shown when transcription is available)
                if let transcription = speechManager.transcription, !transcription.isEmpty {
                    Button(action: onSubmit) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
            
            // Error message if any
            if let errorMessage = speechManager.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Helper computed properties
    
    private var buttonColor: Color {
        switch speechManager.state {
        case .recording:
            return .red
        case .processing:
            return .orange
        case .error:
            return .red
        default:
            return .blue
        }
    }
    
    private var Icon: Image {
        switch speechManager.state {
        case .recording:
            return Image(systemName: "stop.fill")
        case .processing:
            return Image(systemName: "waveform")
        case .error:
            return Image(systemName: "exclamationmark.triangle.fill")
        default:
            return Image(systemName: "mic.fill")
        }
    }
    
    private var statusText: String {
        switch speechManager.state {
        case .idle:
            return speechManager.transcription == nil ? "Ready to record" : "Recording complete"
        case .recording:
            return "Recording..."
        case .processing:
            return "Processing..."
        case .error:
            return "Error occurred"
        default:
            return "Ready"
        }
    }
    
    private var instructionText: String {
        switch speechManager.state {
        case .idle:
            return speechManager.transcription == nil ? "Tap to start recording" : "Tap to record again"
        case .recording:
            return "Tap to stop recording"
        case .processing:
            return "Please wait"
        case .error:
            return "Try again"
        default:
            return "Tap to record"
        }
    }
    
    // MARK: - Actions
    
    private func handleRecordButton() {
        switch speechManager.state {
        case .idle:
            speechManager.startRecording()
        case .recording:
            speechManager.stopRecording()
        case .error:
            speechManager.state = .idle
            speechManager.errorMessage = nil
        default:
            // Do nothing for other states
            break
        }
    }
}

struct SpeechRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            
            SpeechRecorderView(
                speechManager: SpeechManager(
                    audioRecorder: AudioRecorderManager(),
                    transcriptionManager: TranscriptionManager(apiToken: getApiKey() ?? "Bruh")
                ),
                onSubmit: {}
            )
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
