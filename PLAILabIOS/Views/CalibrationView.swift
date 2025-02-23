import SwiftUI
import Vision

// When someone does calibration, they have to have a set position. This means that they would need a way to tell the app to start recording when doing the calibration because they won't be able to press a button on the phone.

// all the calibration should be in the start for each category, sitting, standing, bed


// https://developer.apple.com/tutorials/app-dev-training/transcribing-speech-to-text looks like a good tutorial

struct CalibrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var poseEstimator: PoseEstimator
    
    private var exercise: String
    
    @State private var currentStep = 0
    @State private var isRecording = false
    @State private var calibrationComplete = false
    
    // Store the highest and lowest positions
    @State private var maxArmPosition: CGFloat = 0
    @State private var minSquatPosition: CGFloat = 1
    
    // Timer for measurements
    @State private var remainingTime = 5
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let steps = [
        (title: "Stand Normally", instruction: "Stand in a neutral position with arms at your sides"),
        (title: "Raise Arms", instruction: "Raise your arms as high as you comfortably can"),
        (title: "Deep Squat", instruction: "Perform a squat as low as you comfortably can")
    ]
    
    init(exercise: String) {
        self._poseEstimator = StateObject(wrappedValue: PoseEstimator(selectedExercise: exercise,maxArmPosition: 0,maxSquatPosition: 0))
        self.exercise = exercise
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
            
            
            NavigationLink(destination: BodyPoseDetectionView(
                exercise: self.exercise,
                maxArmPosition: self.maxArmPosition,
                maxSquatPosition: self.minSquatPosition
            ), isActive: $calibrationComplete) {
                EmptyView()
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
                if leftWrist.x != 0 && leftWrist.y != 1 && rightWrist.y != 1 && rightWrist.x != 0 { // Whenever wrist goes out of screen, then it will assign the body joint (0,1) which means that it thinks it is at the top of the page.
                    let maxHeight = max(rightWrist.y, leftWrist.y) // maximum height of the one of the arms
                    maxArmPosition = max(maxArmPosition, maxHeight)
                }
            }
            
        case 2: // Squat
            if let rightHip = bodyParts[.rightHip]?.location,
               let leftHip = bodyParts[.leftHip]?.location {
                let hipHeight = min(rightHip.y, leftHip.y)
                // The bug does not apply here because we are looking for a min rather than a max, so there will be some points where it is (0,1) because it doesn't see the hip, but that is ok because we are minning it. 
                minSquatPosition = min(minSquatPosition, hipHeight) // minimum height for the persons hip
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

