import SwiftUI

struct BodyPoseDetectionView: View {
    let exercise: String // taken from Welcome View Selection
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var poseEstimator: PoseEstimator
    
    // Timer related properties
    @State private var counter = 0
    private let timerLimit = 60
    @State private var timer: Timer? = nil
    @State private var isTimerRunning = false
    
    // Constructor
    init(exercise: String) {
        self.exercise = exercise
        self._poseEstimator = StateObject(wrappedValue: PoseEstimator(selectedExercise: exercise))
    }
    
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geo in
                    CameraViewWrapper(poseEstimator: poseEstimator)
                    GameView(poseEstimator: poseEstimator, size: geo.size, exercise: exercise)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .frame(width: UIScreen.main.bounds.size.width,
                   height: UIScreen.main.bounds.size.width * 1920 / 1080,
                   alignment: .center)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                            Text("Back")
                                .font(.system(size: 18))
                        }
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
            }
            
            // Exercise count display
            HStack {
                Text("\(exercise) :")
                    .font(.title)
                Text(String(poseEstimator.exerciseCount))
                    .font(.title)
            }
            
            // Timer display
            HStack {
                Text("Timer: ")
                    .font(.title2)
                Text("\(timerLimit - counter)") // for a 30 second break
                    .font(.title2)
            }
            
            // Timer controls
            HStack(spacing: 20) {
                Button(action: startTimer) {
                    Text("Start Timer")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: stopTimer) {
                    Text("Stop Timer")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 50)
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            stopTimer() // Make sure to stop timer when view disappears
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    // Timer functions
    private func startTimer() {
        stopTimer() // Invalidate any existing timer
        
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.counter += 1
        }
        // Check if counter has reached the limit
        if self.counter >= self.timerLimit {
            self.stopTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
}
