import SwiftUI
import Vision

struct CalibrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var poseEstimator: PoseEstimator
    
    @State private var currentStep = 0
    @State private var isRecording = false
    @State private var calibrationComplete = false
    
    // Store the highest and lowest positions
    @State private var maxArmPosition: CGFloat = 0
    @State private var minSquatPosition: CGFloat = 1
    
    // Timer for measurements
    @State private var remainingTime = 3
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let steps = [
        (title: "Stand Normally", instruction: "Stand in a neutral position with arms at your sides"),
        (title: "Raise Arms", instruction: "Raise your arms as high as you comfortably can"),
        (title: "Deep Squat", instruction: "Perform a squat as low as you comfortably can")
    ]
    
    init(exercise: String) {
        self._poseEstimator = StateObject(wrappedValue: PoseEstimator(selectedExercise: exercise))
    }
    
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geo in
                    CameraViewWrapper(poseEstimator: poseEstimator)
                    StickFigureView(poseEstimator: poseEstimator, size: geo.size)
                }
            }
            .frame(
                width: UIScreen.main.bounds.size.width,
                height: UIScreen.main.bounds.size.width * 1920 / 1080,
                alignment: .center
            )
            
            VStack(spacing: 20) {
                Text(steps[currentStep].title)
                    .font(.title)
                    .bold()
                
                Text(steps[currentStep].instruction)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if isRecording {
                    Text("Hold position: \(remainingTime)s")
                        .font(.title2)
                        .foregroundColor(.blue)
                } else {
                    Button(action: startRecording) {
                        Text("Start Recording")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                
                // Progress indicators
                HStack {
                    ForEach(0..<steps.count) { step in
                        Circle()
                            .fill(step == currentStep ? Color.blue : Color.gray)
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding(.bottom, 50)
        }
        .onReceive(timer) { _ in
            if isRecording {
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    recordMeasurement()
                }
            }
        }
        .onReceive(poseEstimator.$bodyParts) { bodyParts in
            if isRecording {
                updateMeasurements(from: bodyParts)
            }
        }
        .alert(isPresented: $calibrationComplete) {
            Alert(
                title: Text("Calibration Complete"),
                message: Text("Range of motion recorded:\nMax arm height: \(String(format: "%.2f", maxArmPosition))\nMin squat height: \(String(format: "%.2f", minSquatPosition))"),
                dismissButton: .default(Text("Continue")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func startRecording() {
        isRecording = true
        remainingTime = 3
    }
    
    private func updateMeasurements(from bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        switch currentStep {
        case 1: // Arm raise
            if let rightWrist = bodyParts[.rightWrist]?.location,
               let leftWrist = bodyParts[.leftWrist]?.location {
                let maxHeight = max(rightWrist.y, leftWrist.y)
                maxArmPosition = max(maxArmPosition, maxHeight)
            }
            
        case 2: // Squat
            if let rightHip = bodyParts[.rightHip]?.location,
               let leftHip = bodyParts[.leftHip]?.location {
                let hipHeight = min(rightHip.y, leftHip.y)
                minSquatPosition = min(minSquatPosition, hipHeight)
            }
            
        default:
            break
        }
    }
    
    private func recordMeasurement() {
        isRecording = false
        
        // Move to next step or finish
        if currentStep < steps.count - 1 {
            currentStep += 1
        } else {
            calibrationComplete = true
        }
    }
}

