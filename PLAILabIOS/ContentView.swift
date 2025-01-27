import SwiftUI
import AVFoundation
import Vision

// 1. Application main interface
struct ContentView: View {
    
    @State private var handPoseInfo: String = "Detecting hand poses..."
    @State private var handPoints: [CGPoint] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScannerView(handPoseInfo: $handPoseInfo, handPoints: $handPoints)
            
            // Draw lines between finger joints and the wrist
            Path { path in
                let fingerJoints = [
                    [1, 2, 3, 4],    // Thumb joints (thumbCMC -> thumbMP -> thumbIP -> thumbTip)
                    [5, 6, 7, 8],    // Index finger joints
                    [9, 10, 11, 12],  // Middle finger joints
                    [13, 14, 15, 16],// Ring finger joints
                    [17, 18, 19, 20] // Little finger joints
                ]
                
                if let wristIndex = handPoints.firstIndex(where: { $0 == handPoints.first }) {
                    for joints in fingerJoints {
                        guard joints.count > 1 else { continue }

                        // Connect wrist to the first joint of each finger
                        if joints[0] < handPoints.count {
                            let firstJoint = handPoints[joints[0]]
                            let wristPoint = handPoints[wristIndex]
                            path.move(to: wristPoint)
                            path.addLine(to: firstJoint)
                        }

                        // Connect the joints within each finger
                        for i in 0..<(joints.count - 1) {
                            if joints[i] < handPoints.count && joints[i + 1] < handPoints.count {
                                let startPoint = handPoints[joints[i]]
                                let endPoint = handPoints[joints[i + 1]]
                                path.move(to: startPoint)
                                path.addLine(to: endPoint)
                            }
                        }
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 3)
            
            // Draw circles for the hand points, including the wrist
            ForEach(handPoints, id: \.self) { point in
                Circle()
                    .fill(.red)
                    .frame(width: 15)
                    .position(x: point.x, y: point.y)
            }

            Text(handPoseInfo)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 50)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// 2. Implementing the view responsible for detecting the hand pose
struct ScannerView: UIViewControllerRepresentable {
    
    @Binding var handPoseInfo: String
    @Binding var handPoints: [CGPoint]
    
    let captureSession = AVCaptureSession()
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            return viewController
        }
        
        captureSession.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(videoOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        Task {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 3. Implementing the Coordinator class
        class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
            var parent: ScannerView

            init(_ parent: ScannerView) {
                self.parent = parent
            }

            func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
                guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                    return
                }
                self.detectHandPose(in: pixelBuffer)
            }

            func detectHandPose(in pixelBuffer: CVPixelBuffer) {
                let request = VNDetectHumanHandPoseRequest { (request, error) in
                    guard let observations = request.results as? [VNHumanHandPoseObservation], !observations.isEmpty else {
                        DispatchQueue.main.async {
                            self.parent.handPoseInfo = "No hand detected"
                            self.parent.handPoints = []
                        }
                        return
                    }
                    
                    if let observation = observations.first {
                        var points: [CGPoint] = []
                        
                        // Loop through all recognized points for each finger, including wrist
                        let handJoints: [VNHumanHandPoseObservation.JointName] = [
                            .wrist,  // Wrist joint
                            .thumbCMC, .thumbMP, .thumbIP, .thumbTip,   // Thumb joints
                            .indexMCP, .indexPIP, .indexDIP, .indexTip, // Index finger joints
                            .middleMCP, .middlePIP, .middleDIP, .middleTip, // Middle finger joints
                            .ringMCP, .ringPIP, .ringDIP, .ringTip,     // Ring finger joints
                            .littleMCP, .littlePIP, .littleDIP, .littleTip // Little finger joints
                        ]
                        
                        for joint in handJoints {
                            if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.5 {
                                points.append(recognizedPoint.location)
                            }
                        }
                        
                        // Convert normalized Vision points to screen coordinates and update coordinates
                        self.parent.handPoints = points.map { self.convertVisionPoint($0) }
                        self.parent.handPoseInfo = "Hand detected with \(points.count) points"
                    }
                }

                request.maximumHandCount = 1

                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    print("Hand pose detection failed: \(error)")
                }
            }

            // Convert Vision's normalized coordinates to screen coordinates
            func convertVisionPoint(_ point: CGPoint) -> CGPoint {
                let screenSize = UIScreen.main.bounds.size
                let y = point.x * screenSize.height
                let x = point.y * screenSize.width
                return CGPoint(x: x, y: y)
            }
        }
}
