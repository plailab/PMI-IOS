import SwiftUI

struct CrossBodyReachGameView: ExerciseGameViewProtocol {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    @State var arrowLeft: Bool = true
    @State var neckPos: CGPoint = .zero
    let touchingOffset: CGFloat = 50.0
    @State var arrows: [Arrow] = []
    @State private var frameIndex = 1
    let frameCount = 3 // number of pacman figures to animate, currently 3
    
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
            if poseEstimator.bodyParts[.leftWrist]?.x ?? 0 != 0 {
                Image("pacman\(frameIndex)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .rotationEffect(Angle(degrees: 90))
                    .position(inversePoint(poseEstimator.bodyParts[.leftWrist]!.location, in: size))
            }

            if poseEstimator.bodyParts[.rightWrist]?.x ?? 0 != 0 {
                Image("pacman\(frameIndex)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .rotationEffect(Angle(degrees: 90))
                    .scaleEffect(x: -1, y: 1) // Reflect across Y-axis
                    .position(inversePoint(poseEstimator.bodyParts[.rightWrist]!.location, in: size))
            }
            
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
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                // Loop through frames
                frameIndex = (frameIndex % frameCount) + 1
            }
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
                
                let touchedArrowsCount = arrows.filter { $0.touched }.count
                let expectedLastArrow = arrowLeft ? arrows.first : arrows.last

                if touchedArrowsCount >= 2, expectedLastArrow?.touched == true {
                    // At least 2 arrows touched AND the correct end arrow is touched (based on direction)
                    arrows = createArrows(screenWidth: geometry.size.width, screenHeight: geometry.size.height, yPos: neckPos.y)
                    
                    if !arrowLeft {
                        poseEstimator.exerciseCount += 1
                    }

                    arrowLeft.toggle()
                    AudioPlayer.playScore()
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
