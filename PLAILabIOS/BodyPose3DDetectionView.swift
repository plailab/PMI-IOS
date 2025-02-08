import SwiftUI
import SceneKit
import AVFoundation
import Vision

class HumanBodyPose3DDetector: ObservableObject {
    @Published var humanObservation: VNHumanBodyPose3DObservation?
    
    private var cameraSession: AVCaptureSession?
    
    init() {
        setupCamera()
    }
    
    private func setupCamera() {
        cameraSession = AVCaptureSession()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              let captureSession = cameraSession else {
            return
        }
        
        captureSession.beginConfiguration()
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
        
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
    }
}

extension HumanBodyPose3DDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let bodyPoseRequest = VNDetectHumanBodyPose3DRequest { [weak self] request, error in
            guard let results = request.results as? [VNHumanBodyPose3DObservation],
                  let observation = results.first else {
                return
            }
            
            DispatchQueue.main.async {
                self?.humanObservation = observation
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        
        do {
            try handler.perform([bodyPoseRequest])
        } catch {
            print("Failed to perform body pose detection: \(error)")
        }
    }
}

struct BodyPose3DView: View {
    @StateObject private var detector = HumanBodyPose3DDetector()
    @State private var showCamera = false
    
    var scene: SCNScene {
        let scene = SCNScene()
        
        guard let observation = detector.humanObservation,
              let recognizedPoints = try? observation.recognizedPoints3D(.all) else {
            return scene
        }
        
        // Create joints
        for (jointName, point) in recognizedPoints {
            if point.confidence > 0.3 {
                let jointNode = createJointNode(at: point.position)
                jointNode.name = jointName.rawValue
                scene.rootNode.addChildNode(jointNode)
            }
        }
        
        // Create connections
        let connections: [(VNHumanBodyPose3DObservation.JointName, VNHumanBodyPose3DObservation.JointName)] = [
           
            (.leftElbow, .leftShoulder),
            (.rightElbow, .rightShoulder),
            (.leftWrist, .leftElbow),
            (.rightWrist, .rightElbow),
            (.leftHip, .root),
            (.rightHip, .root),
            (.leftKnee, .leftHip),
            (.rightKnee, .rightHip),
            (.leftAnkle, .leftKnee),
            (.rightAnkle, .rightKnee)
        ]
        
        for (start, end) in connections {
            if let startPoint = recognizedPoints[start],
               let endPoint = recognizedPoints[end],
               startPoint.confidence > 0.3,
               endPoint.confidence > 0.3 {
                let connection = createConnection(from: startPoint.position, to: endPoint.position)
                scene.rootNode.addChildNode(connection)
            }
        }
        
        // Add camera
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        scene.rootNode.addChildNode(cameraNode)
        
        // Add lighting
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        return scene
    }
    
    private func createJointNode(at position: simd_float3) -> SCNNode {
        let geometry = SCNSphere(radius: 0.05)
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        
        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3(position)
        return node
    }
    
    private func createConnection(from start: simd_float3, to end: simd_float3) -> SCNNode {
        let vector = end - start
        let distance = simd_length(vector)
        
        let cylinder = SCNCylinder(radius: 0.02, height: CGFloat(distance))
        cylinder.firstMaterial?.diffuse.contents = UIColor.blue
        
        let node = SCNNode(geometry: cylinder)
        
        // Position and orient the cylinder
        let midPoint = (start + end) / 2
        node.position = SCNVector3(midPoint)
        
        // Calculate rotation
        let direction = simd_normalize(vector)
        let rotationMatrix = simd_float3x3(from: simd_float3(0, 1, 0), to: direction)
        if let rotation = rotationMatrix {
            node.simdOrientation = simd_quatf(rotation)
        }
        
        return node
    }
    
    var body: some View {
        VStack {
            SceneView(
                scene: scene,
                options: [.autoenablesDefaultLighting, .allowsCameraControl]
            )
            
            Button("Close") {
                // Add dismiss action here
            }
            .padding()
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
        }
    }
}
