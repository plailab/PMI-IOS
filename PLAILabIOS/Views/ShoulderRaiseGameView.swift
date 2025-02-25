import SwiftUI

struct ShoulderRaiseGameView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    @State private var frameIndex = 1
    let frameCount = 3 // number of pacman figures to animate, currently 3
    @State private var dotPositionLeft = CGPoint(x: 0, y: 0)
    @State private var dotPositionRight = CGPoint(x: 0, y: 0)
    @State private var showDotTop = true // start at top by default
    
    @State private var armLength = CGFloat(0)
    
    let touchingOffset: CGFloat = 30.0
    let dotOffsetY: CGFloat = 200.0
    
    var body: some View {
        if poseEstimator.bodyParts.isEmpty == false {
            ZStack {
                // consider using a more visual element, avoiding similar color with background
                Image("strawberry")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .position(dotPositionLeft)
                Image("strawberry")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .position(dotPositionRight)
                
                // hide the pacman if it is outside of the two sides of the screen
                if poseEstimator.bodyParts[.leftWrist]?.x ?? 0 != 0 {
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
                }
                
                if poseEstimator.bodyParts[.rightWrist]?.x ?? 0 != 0 {
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
                        
                        // calculating the arm lengths and dynamically updating the lengths for dots' y offset
                        if let leftElbow = poseEstimator.bodyParts[.leftElbow]?.location,
                           let rightElbow = poseEstimator.bodyParts[.rightElbow]?.location {
                            
                            // Inverse the elbow points first
                            let invLeftElbow = inversePoint(leftElbow, in: size)
                            let invRightElbow = inversePoint(rightElbow, in: size)
                            
                            // Compute distances using inverted elbow points
                            let leftTotalArm = inverseLeftShoulder.distance(to: invLeftElbow) + invLeftElbow.distance(to: inverseLeftWrist)
                            let rightTotalArm = inverseRightShoulder.distance(to: invRightElbow) + invRightElbow.distance(to: inverseRightWrist)
                            
                            // Update arm length with the max inverted distance
                            armLength = max(leftTotalArm, rightTotalArm)
                            //                            print(armLength)
                        }
                        
                        
                        // Check if the dots are initially (0,0) and set them to the top position
                        if dotPositionLeft == .zero && dotPositionRight == .zero {
                            
                            // Initial position
                            dotPositionLeft = (inverseLeftShoulder - CGPoint(x: 0, y: dotOffsetY)).bounded(to: size)
                            dotPositionRight = (inverseRightShoulder - CGPoint(x: 0, y: dotOffsetY)).bounded(to: size)
                            
                            showDotTop = true // Start at the top
                        }
                        
                        if showDotTop {
                            // Check if both wrists are close enough to their respective "top" positions
                            if dotPositionLeft.distance(to: inverseLeftWrist) <= touchingOffset &&
                                dotPositionRight.distance(to: inverseRightWrist) <= touchingOffset {
                                
                                showDotTop.toggle()
                                
                                // Move dots to the bottom position
                                dotPositionLeft = (inverseLeftShoulder + CGPoint(x: -armLength/2, y: 40)).bounded(to: size)
                                dotPositionRight = (inverseRightShoulder + CGPoint(x: armLength/2, y: 40)).bounded(to: size)
                            }
                        } else {
                            // Check if both wrists are touching their respective "bottom" positions
                            if dotPositionLeft.distance(to: inverseLeftWrist) <= touchingOffset &&
                                dotPositionRight.distance(to: inverseRightWrist) <= touchingOffset {
                                
                                showDotTop.toggle()
                                
                                // Move dots to the top position
                                dotPositionLeft = (inverseLeftShoulder - CGPoint(x: 0, y: armLength)).bounded(to: size)
                                dotPositionRight = (inverseRightShoulder - CGPoint(x: 0, y: armLength)).bounded(to: size)
                            }
                        }
                        
                    }
                }
                
            }
        }
    }
}
