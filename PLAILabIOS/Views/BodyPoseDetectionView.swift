import SwiftUI


// In the future, how do we want to decide sets and how many reps?
// Should not push until failure
// Create a reminder for them every day (push notifs?)
// https://www.nhs.uk/live-well/exercise/physical-activity-guidelines-older-adults/
// Do we want to start saving information? (save account info and use firebase?)



struct BodyPoseDetectionView: View {
    let exercise: String // taken from Welcome View Selection
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var poseEstimator: PoseEstimator
    
    // Timer and exercise related properties
    @State private var counter = 0
    private let timerLimit = 60 // timer for rest
    @State private var setCount = 0
    @State private var timer: Timer? = nil
    @State private var isTimerRunning = false
    @State private var isResting = false // Track if in rest period
    @State private var lastExerciseCount = 0 // To track previous exercise count
    private let repsPerSet = 12
    
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
                    StickFigureView(poseEstimator: poseEstimator, size: geo.size)
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
            
            // Exercise and set information display
            VStack(spacing: 15) {
                HStack {
                    Text("\(exercise) Count:")
                        .font(.title)
                    Text(String(isResting ? lastExerciseCount : poseEstimator.exerciseCount))
                        .font(.title)
                }
                
                HStack {
                    Text("Set:")
                        .font(.title2)
                    Text("\(setCount)")
                        .font(.title2)
                }
                
                // Status and timer display
                if isResting {
                    Text("REST TIME")
                        .font(.title)
                        .bold()
                        .foregroundColor(.red)
                        .padding()
                    
                    HStack {
                        Text("Time Remaining:")
                            .font(.title2)
                        Text("\(timerLimit - counter)")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                    HStack(spacing: 20) {
                        Button(action: {
                            // Skip rest
                            endRestPeriod()
                        }) {
                            Text("Skip Rest")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.bottom, 150)
                } else {
                    Text("WORKOUT TIME")
                        .font(.title)
                        .bold()
                        .foregroundColor(.green)
                        .padding()
                }
            }
            
            
            
            Spacer()
        }
        .padding(.bottom, 50)
        .onChange(of: poseEstimator.exerciseCount) { newCount in
            // Check if we've completed a set and should start resting
            if !isResting && newCount >= repsPerSet {
                startRestPeriod()
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            stopTimer()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    // Start rest period after completing a set
    private func startRestPeriod() {
        isResting = true
        lastExerciseCount = poseEstimator.exerciseCount
        setCount += 1
        counter = 0
        startTimer()
    }
    
    // End rest period and prepare for next set
    private func endRestPeriod() {
        stopTimer()
        isResting = false
        counter = 0
        // Reset the exercise count in PoseEstimator
        poseEstimator.exerciseCount = 0
    }
    
    // Timer functions
    private func startTimer() {
        stopTimer() // Invalidate any existing timer
        
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.counter += 1
            
            // Check if counter has reached the limit
            if self.counter >= self.timerLimit {
                self.endRestPeriod()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
}
