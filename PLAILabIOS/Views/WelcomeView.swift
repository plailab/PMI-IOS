import SwiftUI

struct WelcomeView: View {
    @State private var showBodyCamera = false
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.2).edgesIgnoringSafeArea(.all) // Changes whole background color
            
            VStack(spacing: 40) {
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

        .fullScreenCover( isPresented: $showBodyCamera){
            BodyPoseDetectionView()
        }
    }
}

#Preview {
    WelcomeView()
}
