import SwiftUI

struct BodyPoseDetectionView: View {
    let exercise: String // taken from Welcome View Selection
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var poseEstimator: PoseEstimator
    
    // Seems like the constructor
    // Makes sure that the passed in parameter gets assigned to this class
    init(exercise: String) {
        
        self.exercise = exercise
        
        // Create the StateObject after self.exercise is initialized
        
        // NEED TO PASS IN THE VALUES TO THE POSEESTIMATOR SO IT CAN ACTUALLY USE IT FOR EXERCISES
        self._poseEstimator = StateObject(wrappedValue: PoseEstimator(selectedExercise: exercise))
    }
    
    
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geo in
                    CameraViewWrapper(poseEstimator: poseEstimator)
                    //                    StickFigureView(poseEstimator: poseEstimator, size: geo.size)
                    GameView(poseEstimator: poseEstimator, size: geo.size, exercise: exercise)
                }
            }.edgesIgnoringSafeArea(.all)
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 1920 / 1080, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            // make back button more obvious
            //            .navigationBarBackButtonHidden(true) // Hide default back button
                .navigationBarBackButtonHidden(true) // Hide default back button
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss() // Navigate back
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Back")
                                    .font(.system(size: 18))
                            }
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.blue) // Background color
                            .cornerRadius(8)
                        }
                    }
                }
            
            
            HStack {
                Text("\(exercise) :")
                    .font(.title)
                Text(String(poseEstimator.exerciseCount)) // This needs to be changed to be dependent on the exercise
                // maybe i should have a struct so that if they choose the shoulder raise variable, there is a thing for the count and that stuff automatically
                    .font(.title)
                
            }.padding(.bottom, 50)
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
}

