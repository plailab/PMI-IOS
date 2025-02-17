import SwiftUI

struct CallibrationView: View {
    
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var poseEstimator: PoseEstimator
    
    var isFinished = false
    var callibrationData: [String: [String : [Float]]] = ["HighArmY": [:],
                                                          "LowSquatY": [:] ]
    
    
    // need a order list
    
                             
    // Seems like the constructor
    // Makes sure that the passed in parameter gets assigned to this class
    init(exercise: String) {
            // Create the StateObject after self.exercise is initialized
            self._poseEstimator = StateObject(wrappedValue: PoseEstimator(selectedExercise: exercise))
    }
        
    
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geo in
                    CameraViewWrapper(poseEstimator: poseEstimator)
                    StickFigureView(poseEstimator: poseEstimator, size: geo.size)
                }
            }.frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 1920 / 1080, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
           
            HStack {
                Text("Callibration Time!") // This needs to be changed to be dependent on the exercise
                // maybe i should have a struct so that if they choose the shoulder raise variable, there is a thing for the count and that stuff automatically
                    .font(.title)
                
                
                // Text(\()) NEED TO SAY WHAT TO DO SO I NEED A LIST FOR THIS 
                
                // NOTE: In the future, make a mark for good form
//                Image(systemName: "exclamationmark.triangle.fill")
//                    .font(.largeTitle)
//                    .foregroundColor(Color.red)
//                    .opacity(poseEstimator.isGoodPosture ? 0.0 : 1.0)
          
            }.padding(.bottom, 50)
        }
    }
}

