import SwiftUI

struct LegRaiseGameView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    @State private var frameIndex = 4
    let frameCount = 3 // number of pacman figures to animate, currently 3
    @State private var dotPositionLeft = CGPoint(x: 0, y: 0)
    @State private var dotPositionRight = CGPoint(x: 0, y: 0)
    @State private var showDotTop = true // start at top by default
    
    let touchingOffset: CGFloat = 30.0
    let dotOffsetY: CGFloat = 200.0
    
    var body: some View {
        if poseEstimator.bodyParts.isEmpty == false {
            ZStack {
//                 consider using a more visual element, avoiding similar color with background
                Image("goldblock/goldblock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .position(CGPoint(x: 50, y: 50))
                    .onAppear {
                        // Start the timer when the view appears
                        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                            // Loop through frames
                            frameIndex = (frameIndex % frameCount) + 1
                        }
                    }
                
                // hide the pacman if it is outside of the two sides of the screen
                if poseEstimator.bodyParts[.leftAnkle]?.x ?? 0 != 0 {
                    Image("mario-running") // Switch images based on the condition
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .position(inversePoint(poseEstimator.bodyParts[.leftAnkle]!.location, in: size))
                }
                
                if poseEstimator.bodyParts[.rightAnkle]?.x ?? 0 != 0 {
                    Image("luigi-running") // Switch images based on the condition
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .position(inversePoint(poseEstimator.bodyParts[.rightAnkle]!.location, in: size))
                }
            }
            .onChange(of: poseEstimator.bodyParts) { _ in
                // Update points whenever the bodyParts change
                        
                
            }
        }
    }
}
