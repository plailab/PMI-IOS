import SwiftUI

struct ShoulderRaiseGameView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    @State private var frameIndex = 1
    let frameCount = 3 // number of pacman figures to animate, currently 3
    @State private var dotPositionLeft = CGPoint(x: 0, y: 0)
    @State private var dotPositionRight = CGPoint(x: 0, y: 0)
    @State private var showDotTop = true // start at top by default
    
    let touchingOffset: CGFloat = 30.0
    let dotOffsetY: CGFloat = 200.0
    // dotOffsetX is a state var so that it does not flick around during the view (memorized)
    @State var dotOffsetX = CGFloat.random(in: -50...50)
    
    var body: some View {
        if poseEstimator.bodyParts.isEmpty == false {
            ZStack {
                Image("dot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .position(dotPositionLeft)
                Image("dot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .position(dotPositionRight)
                
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
                        
                        // Check if the dots are initially (0,0) and set them to the top position
                        if dotPositionLeft == .zero && dotPositionRight == .zero {
                            
                            // initial position
                            dotPositionLeft = inverseLeftShoulder - CGPoint(x: 0, y: dotOffsetY)
                            dotPositionRight = inverseRightShoulder - CGPoint(x: 0, y: dotOffsetY)

                            showDotTop = true // Start at the top
                        }
                        // TODO: make the offsets proportional to body to resolve depth issue. Idea: for x offset for bottom position, take the distance of forarm. For top, just the sum of the length of the whole arm (maybe times 0.8)

                        if showDotTop {
                            // Check if both wrists are close enough to their respective "top" positions
                            if dotPositionLeft.distance(to: inverseLeftWrist) <= touchingOffset &&
                               dotPositionRight.distance(to: inverseRightWrist) <= touchingOffset {
                                
                                showDotTop.toggle()
                                dotOffsetX = CGFloat.random(in: -50...50)
                                
                                // Move dots to the bottom position
                                dotPositionLeft = inverseLeftShoulder + CGPoint(x: dotOffsetX, y: 0)
                                dotPositionRight = inverseRightShoulder + CGPoint(x: dotOffsetX, y: 0)
                            }
                        } else {
                            // Check if both wrists are touching their respective "bottom" positions
                            if dotPositionLeft.distance(to: inverseLeftWrist) <= touchingOffset &&
                               dotPositionRight.distance(to: inverseRightWrist) <= touchingOffset {
                                
                                showDotTop.toggle()
                                dotOffsetX = CGFloat.random(in: -50...50)

                                // Move dots to the top position
                                dotPositionLeft = inverseLeftShoulder - CGPoint(x: dotOffsetX, y: dotOffsetY)
                                dotPositionRight = inverseRightShoulder - CGPoint(x: dotOffsetX, y: dotOffsetY)
                            }
                        }

                    }
                }

            }
        }
    }
}
