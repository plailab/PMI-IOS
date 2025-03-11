import SwiftUI

struct CrossBodyReachGameView: ExerciseGameViewProtocol {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    @State var arrowLeft: Bool = true
    @State var neckPos: CGPoint = .zero
    let touchingOffset: CGFloat = 30.0
    @State var arrows: [Arrow] = []
    
    struct Arrow: Hashable {
        var pos: CGPoint
        var touched: Bool = false
    }
    
    // Function to create and store five arrows at the same yPos
    func createArrows(screenWidth: CGFloat, screenHeight: CGFloat, yPos: CGFloat) -> [Arrow] {
        let positions = [
            CGPoint(x: screenWidth * 0.1, y: yPos), // Left 1
            CGPoint(x: screenWidth * 0.25, y: yPos), // Left 2
            CGPoint(x: screenWidth * 0.5, y: yPos),  // Center
            CGPoint(x: screenWidth * 0.75, y: yPos), // Right 2
            CGPoint(x: screenWidth * 0.9, y: yPos)   // Right 1
        ]
        
        var arrowsArray: [Arrow] = []
        
        // Add arrows at the specified positions with alternating rotations
        for (_, position) in positions.enumerated() {
            arrowsArray.append(Arrow(pos: position))
        }
        return arrowsArray
    }
    
    // Implement the required function
    func createGameViewContent(geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        
        return ZStack {
            ForEach(arrows, id: \.self) { arrow in
                if !arrow.touched{
                    Image("arrow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .rotationEffect(arrowLeft ? .degrees(-90) : .degrees(90)) // Rotate if at bottom
                        .position(arrow.pos)
                }
            }
        }.onAppear {
            if let neck = poseEstimator.bodyParts[.neck]?.location {
                neckPos = inversePoint(neck, in: size)
            } else{
                neckPos = CGPoint(x: screenWidth/2, y: screenHeight/2)
            }
            arrows = createArrows(screenWidth: screenWidth, screenHeight: screenHeight, yPos: neckPos.y)
        }.onChange(of: poseEstimator.bodyParts) { _ in
            // Update points whenever the bodyParts change
            if let leftWrist = poseEstimator.bodyParts[.leftWrist]?.location,
               let rightWrist = poseEstimator.bodyParts[.rightWrist]?.location {
                
                let invLeftWrist = inversePoint(leftWrist, in: size)
                let invRightWrist = inversePoint(rightWrist, in: size)
                
                // Iterate through each arrow and check if it has been touched
                for index in arrows.indices {
                    let arrow = arrows[index]
                    
                    // Check if the left wrist is close enough to the arrow and mark as touched
                    if !arrow.touched && !arrowLeft && (invLeftWrist.distance(to: arrow.pos) < touchingOffset) {
                        arrows[index].touched = true
                    }
                    
                    // Check if the right wrist is close enough to the arrow and mark as touched
                    if !arrow.touched && arrowLeft && (invRightWrist.distance(to: arrow.pos) < touchingOffset) {
                        arrows[index].touched = true
                    }
                }
                
                // Update neck position and toggle arrowLeft for the next arrow
                if let neck = poseEstimator.bodyParts[.neck]?.location {
                    neckPos = inversePoint(neck, in: size)
                }
                
                // Toggle the arrowLeft for alternating left-right checks
                if arrows.allSatisfy({ $0.touched }) {
                    // All arrows have been touched, reset or update the state as needed
                    // For example, reset the arrows if desired
                    arrows = createArrows(screenWidth: geometry.size.width, screenHeight: geometry.size.height, yPos: neckPos.y)
                    arrowLeft.toggle()
                    poseEstimator.exerciseCount += 1
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
