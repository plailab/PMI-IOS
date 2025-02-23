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
                    StickFigureView(poseEstimator: poseEstimator, size: geo.size)
                    GameView(poseEstimator: poseEstimator, size: geo.size, exercise: exercise)
                }
            }.frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 1920 / 1080, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
           
            
            HStack {
                Text("\(exercise) counter:")
                    .font(.title)
                Text(String(poseEstimator.exerciseCount)) // This needs to be changed to be dependent on the exercise
                // maybe i should have a struct so that if they choose the shoulder raise variable, there is a thing for the count and that stuff automatically
                    .font(.title)
                
                // NOTE: In the future, make a mark for good form
//                Image(systemName: "exclamationmark.triangle.fill")
//                    .font(.largeTitle)
//                    .foregroundColor(Color.red)
//                    .opacity(poseEstimator.isGoodPosture ? 0.0 : 1.0)
          
            }.padding(.bottom, 50)
        }
    }
}

