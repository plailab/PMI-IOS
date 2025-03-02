import SwiftUI

struct LegRaiseGameView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    @State private var frameIndex = 1
    let normalFrameCount = 4 // Number of frames for gold block animation
    let poppedFrameCount = 3  // Frames for popped version

    @State private var goldBlockPos = CGPoint.zero
    @State private var blockAtTop = false // Start at top by default
    @State private var blockIsHit: Bool = false
    @State private var goldBlockPosUp = CGPoint.zero
    @State private var goldBlockPosDown = CGPoint.zero
    
    
    let touchingOffset: CGFloat = 30.0
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ZStack {
                if !blockIsHit {
                    Image("goldblock/goldblock\(frameIndex)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .rotationEffect(blockAtTop ? .degrees(0) : .degrees(-90)) // Rotate if at bottom
                        .position(goldBlockPos)
                } else {
                    Image("goldblock/popped\(frameIndex)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .rotationEffect(blockAtTop ? .degrees(0) : .degrees(-90)) // Rotate if at bottom
                        .position(goldBlockPos)
                }
                // Display Mario and Luigi based on ankle positions
                if let leftAnkle = poseEstimator.bodyParts[.leftAnkle]?.location {
                    Image("mario-running")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .position(inversePoint(leftAnkle, in: size))
                }
                
                if let rightAnkle = poseEstimator.bodyParts[.rightAnkle]?.location {
                    Image("luigi-running")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .position(inversePoint(rightAnkle, in: size))
                }
            }
            .onAppear {
                startGoldBlockAnimation()
                // Initialize gold block positions based on screen size
                goldBlockPosUp = CGPoint(x: screenWidth * 0.75, y: screenHeight * 0.7)
                goldBlockPosDown = CGPoint(x: screenWidth * 0.25, y: screenHeight * 0.8)
                
                goldBlockPos = blockAtTop ? goldBlockPosUp : goldBlockPosDown
            }
            .onChange(of: poseEstimator.bodyParts) { _ in
                // Update points whenever the bodyParts change
                if let leftAnkle = poseEstimator.bodyParts[.leftAnkle]?.location,
                   let rightAnkle = poseEstimator.bodyParts[.rightAnkle]?.location {
                    
                    let invLeftAnkle = inversePoint(leftAnkle, in: size)
                    let invRightAnkle = inversePoint(rightAnkle, in: size)
                    
                    let goldBlockPosUp = CGPoint(x: screenWidth * 0.75, y: screenHeight * 0.7)
                    let goldBlockPosDown = CGPoint(x: screenWidth * 0.3, y: screenHeight * 0.9)
                    
                    // only check collision when the block is not hit (no checking during animation)
                    if !blockIsHit && (goldBlockPos.distance(to: invLeftAnkle) <= touchingOffset ||
                        goldBlockPos.distance(to: invRightAnkle) <= touchingOffset) {
                        blockIsHit = true
                        frameIndex = 1
                        //only increase the score when it is hitting the top one, given that 1 top 1 bottom is one rep
                        if blockAtTop {
                            poseEstimator.exerciseCount += 1
                        }
                        // Switch back to normal after animation completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + (0.2 * Double(poppedFrameCount))) {
                            frameIndex = 1
                            blockAtTop.toggle()
                            goldBlockPos = blockAtTop ? goldBlockPosUp : goldBlockPosDown
                            blockIsHit = false
                        }
                    }
                }
            }
        }
    }
    
    // Start animation timer for gold block
    private func startGoldBlockAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            frameIndex = (frameIndex % (blockIsHit ? poppedFrameCount : normalFrameCount)) + 1
        }
    }
}
