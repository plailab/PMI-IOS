import SwiftUI

struct WelcomeView: View {
    @State private var showHandCamera = false
    @State private var showBodyCamera = false
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.2).edgesIgnoringSafeArea(.all) // Changes whole background color
            
            VStack(spacing: 40) {
                VStack(){
                    Text("Hand Pose Detection")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Tap to start hand camera")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                 
                    Button(action: {
                        showHandCamera = true
                    }) {
                        Text("Start Detection")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                VStack(){
                    Text("Body Pose Detection")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Tap to start body camera")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                   
                    Button(action: {
                        showBodyCamera = true
                    }) {
                        Text("Start Detection")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
                }
              
        .fullScreenCover(isPresented: $showHandCamera) { // if true, cover the whole screen with this, seems kind of funky because it just sounds like it is a pop up and might not be the most efficient. It's keeping the previous page open and adding this on top, instead of just switching
            HandPoseDetectionView()
        }
        .fullScreenCover( isPresented: $showBodyCamera){
            //BodyPoseDetectionView()
        }
    }
}

#Preview {
    WelcomeView()
}
