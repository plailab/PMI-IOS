import SwiftUI

// Idea: try to place your feet in the bottom center of the screen
// make it up and down facing the camera
struct LegRaiseGameView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    @State private var frameIndex = 1
    let frameCount = 3

    @State private var applePos = CGPoint.zero
    @State private var appleAtTop = true // Start at top by default
    @State private var applePosUp = CGPoint.zero
    @State private var applePosDown = CGPoint.zero
    
    
    let touchingOffset: CGFloat = 60.0
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ZStack {
                if applePos != CGPoint.zero {
                    Image("apple")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .position(applePos)
                }
                // Display Mario and Luigi based on ankle positions
                if let leftAnkle = poseEstimator.bodyParts[.leftAnkle]?.location {
                    Image("pacman\(frameIndex)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .position(inversePoint(leftAnkle, in: size))
                }
                
                if let rightAnkle = poseEstimator.bodyParts[.rightAnkle]?.location {
                    Image("pacman\(frameIndex)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .position(inversePoint(rightAnkle, in: size))
                }
            }
            .onAppear {
                startGoldBlockAnimation()
                // Initialize gold block positions based on screen size
                applePosUp = CGPoint(x: screenWidth * 0.78, y: screenHeight * 0.7)
                applePosDown = CGPoint(x: screenWidth * 0.25, y: screenHeight * 0.75)
                
                applePos = appleAtTop ? applePosUp : applePosDown
            }
            .onChange(of: poseEstimator.bodyParts) { _ in
                // Update points whenever the bodyParts change
                if let leftAnkle = poseEstimator.bodyParts[.leftAnkle]?.location,
                   let rightAnkle = poseEstimator.bodyParts[.rightAnkle]?.location {
                    
                    let invLeftAnkle = inversePoint(leftAnkle, in: size)
                    let invRightAnkle = inversePoint(rightAnkle, in: size)
                    
                    let applePosUp = CGPoint(x: screenWidth * 0.75, y: screenHeight * 0.7)
                    let applePosDown = CGPoint(x: screenWidth * 0.4, y: screenHeight * 0.9)
                    
                    // only check collision when the block is not hit (no checking during animation)
                    if (applePos.distance(to: invLeftAnkle) <= touchingOffset ||
                        applePos.distance(to: invRightAnkle) <= touchingOffset) {
                        frameIndex = 1
                        //only increase the score when it is hitting the top one, given that 1 top 1 bottom is one rep
                        if appleAtTop {
                            poseEstimator.exerciseCount += 1
                        }
                        appleAtTop.toggle()
                        applePos = appleAtTop ? applePosUp : applePosDown
                    }
                }
            }
        }
    }
    
    // Start animation timer for gold block
    private func startGoldBlockAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            frameIndex = (frameIndex % frameCount) + 1
        }
    }
}
