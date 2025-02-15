import SwiftUI

struct BodyPoseDetectionView: View {
    
    let exercise: String // taken from Welcome View Selection
    
    @StateObject var poseEstimator = PoseEstimator()
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        VStack {
            HStack { // horizontal stack
                              Button(action: {
                                  presentationMode.wrappedValue.dismiss()
                              }) {
                                  Image(systemName: "xmark.circle.fill") // EXIT THE SCREEN
                                      .font(.title)
                                      .foregroundColor(.white)
                                      .padding(.top, 20)
                              }

            }.padding([.top, .leading], 20) // leading is left side, trailing is right side
            ZStack {
                GeometryReader { geo in
                    CameraViewWrapper(poseEstimator: poseEstimator)
                    StickFigureView(poseEstimator: poseEstimator, size: geo.size)
                }
            }.frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 1920 / 1080, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
           
            HStack {
                Text("\(exercise) counter:")
                    .font(.title)
                Text(String(poseEstimator.shoulderRaiseCount)) // This needs to be changed to be dependent on the exercise
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

