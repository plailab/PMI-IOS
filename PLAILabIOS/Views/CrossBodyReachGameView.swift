import SwiftUI

struct CrossBodyReachGameView: ExerciseGameViewProtocol {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    @State var arrowLeft: Bool = true
    @State var neckPos: CGPoint = .zero
    let touchingOffset: CGFloat = 30.0
    
    // Implement the required function
    func createGameViewContent(geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        
        return ZStack {
            Image("arrow")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .rotationEffect(arrowLeft ? .degrees(-90) : .degrees(90)) // Rotate if at bottom
                .position(neckPos)
        }.onAppear {
            if let neck = poseEstimator.bodyParts[.neck]?.location {
                neckPos = inversePoint(neck, in: size)
            } else{
                neckPos = CGPoint(x: screenWidth/2, y: screenHeight/2)
            }
        }.onChange(of: poseEstimator.bodyParts) { _ in
            // Update points whenever the bodyParts change
            if let leftWrist = poseEstimator.bodyParts[.leftWrist]?.location,
               let rightWrist = poseEstimator.bodyParts[.rightWrist]?.location {
                
                let invLeftWrist = inversePoint(leftWrist, in: size)
                let invRightWrist = inversePoint(rightWrist, in: size)
                
                if ((arrowLeft && invRightWrist.distance(to: neckPos) < touchingOffset) || ((!arrowLeft) && invLeftWrist.distance(to: neckPos) < touchingOffset)) {
                    poseEstimator.exerciseCount += 1
                    if let neck = poseEstimator.bodyParts[.neck]?.location {
                        neckPos = inversePoint(neck, in: size)
                    }
                    arrowLeft.toggle()
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            createGameViewContent(geometry: geometry)
        }
    }
}
