import SwiftUI

struct WelcomeView: View {
    @State private var selection = "Shoulder Raises"
    let exercises = ["Shoulder Raises", "Knee Extensions (No)", "Raise Them Knees (No)", "Ankle Circles (No)"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.blue.opacity(0.2).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    VStack {
                        Text("PLAIful Movement")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Tap to start playing!")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Picker("Select an exercise", selection: $selection) {
                            ForEach(exercises, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        NavigationLink(destination: BodyPoseDetectionView(exercise:selection)) {
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
        }
    }
}
#Preview {
    WelcomeView()
}
