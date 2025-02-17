import SwiftUI

struct GameView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    let exercise: String
    @State private var frameIndex = 1
    let frameCount = 3 // number of pacman figures to animate, currently 3
    @State private var dotAboveShoulderLeft = CGPoint(x: 0, y: 0)
    @State private var dotAboveShoulderRight = CGPoint(x: 0, y: 0)
    @State private var dotBelowShoulderLeft = CGPoint(x: 0, y: 0)
    @State private var dotBelowShoulderRight = CGPoint(x: 0, y: 0)
    @State private var showDotTop = true // start at top by default
    
    let touchingOffset: CGFloat = 30.0
    let dotOffsetY: CGFloat = 200.0
    @State var dotOffsetX = CGFloat.random(in: -50...50)

    
    var body: some View {
        if poseEstimator.bodyParts.isEmpty == false {
            ZStack {
                if showDotTop {
                    Image("dot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .position(dotAboveShoulderLeft)
                    Image("dot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .position(dotAboveShoulderRight)
                } else {
                    Image("dot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .position(dotBelowShoulderLeft)
                    Image("dot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .position(dotBelowShoulderRight)
                }
                
                Image("pacman\(frameIndex)") // Switch images based on the condition
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .position(inversePoint(poseEstimator.bodyParts[.leftWrist]!.location, in: size))
                    .onAppear {
                        // Start the timer when the view appears
                        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                            // Loop through frames
                            frameIndex = (frameIndex % frameCount) + 1
                        }
                    }
                
                Image("pacman\(frameIndex)") // Switch images based on the condition
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .position(inversePoint(poseEstimator.bodyParts[.rightWrist]!.location, in: size))
                    .onAppear {
                        // Start the timer when the view appears
                        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                            // Loop through frames
                            frameIndex = (frameIndex % frameCount) + 1
                        }
                    }
            }
            .onChange(of: poseEstimator.bodyParts) { _ in
                // Update points whenever the bodyParts change
                print(showDotTop)

                if let leftShoulder = poseEstimator.bodyParts[.leftShoulder]?.location,
                   let rightShoulder = poseEstimator.bodyParts[.rightShoulder]?.location {

                    // Only proceed if both leftWrist and rightWrist are available
                    if let leftWrist = poseEstimator.bodyParts[.leftWrist]?.location,
                       let rightWrist = poseEstimator.bodyParts[.rightWrist]?.location {

                        // Perform inverse calculation on both wrists and shoulders
                        let inverseLeftShoulder = inversePoint(leftShoulder, in: size)
                        let inverseRightShoulder = inversePoint(rightShoulder, in: size)
                        let inverseLeftWrist = inversePoint(leftWrist, in: size)
                        let inverseRightWrist = inversePoint(rightWrist, in: size)
                        
                        // If showDotTop is true, update positions for top
                        if showDotTop {
                            dotAboveShoulderLeft = inverseLeftShoulder - CGPoint(x: dotOffsetX, y: dotOffsetY)
                            dotAboveShoulderRight = inverseRightShoulder - CGPoint(x: dotOffsetX, y: dotOffsetY)
                            
                            // Check if both wrists are close enough to their respective "top" positions
                            if dotAboveShoulderLeft.distance(to: inverseLeftWrist) <= touchingOffset && dotAboveShoulderRight.distance(to: inverseRightWrist) <= touchingOffset {
                                showDotTop.toggle()
                                dotOffsetX = CGFloat.random(in: -50...50)
                            }
                        } else {
                            // If showDotTop is false, update positions for bottom
                            dotBelowShoulderLeft = inverseLeftShoulder + CGPoint(x: dotOffsetX, y: dotOffsetY)
                            dotBelowShoulderRight = inverseRightShoulder + CGPoint(x: dotOffsetX, y: dotOffsetY)

                            // Check if both wrists are touching their respective "bottom" positions
                            if dotBelowShoulderLeft.distance(to: inverseLeftWrist) <= touchingOffset && dotBelowShoulderRight.distance(to: inverseRightWrist) <= touchingOffset {
                                showDotTop.toggle()
                                dotOffsetX = CGFloat.random(in: -50...50)
                            }
                        }
                    }
                }

            }
        }
    }
}
