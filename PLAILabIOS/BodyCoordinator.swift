// Coordinator.swift
import AVFoundation
import Vision
import UIKit

class BodyCoordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var parent: BodyScannerView
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    init(_ parent: BodyScannerView) {
        self.parent = parent
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        self.detectBodyPose(in: pixelBuffer)
    }
    
    func detectBodyPose(in pixelBuffer: CVPixelBuffer) {
        let request = VNDetectHumanBodyPoseRequest { [weak self] (request, error) in
            guard let self = self,
                  let observations = request.results as? [VNHumanBodyPoseObservation],
                  !observations.isEmpty else {
                DispatchQueue.main.async {
                    self?.parent.bodyPoseInfo = "No body detected"
                    self?.parent.bodyPoints = []
                }
                return
            }
            
            if let observation = observations.first {
                var points: [CGPoint] = []
                
                let handJoints: [VNHumanBodyPoseObservation.JointName] = [
                    .wrist,
                    .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
                    .indexMCP, .indexPIP, .indexDIP, .indexTip,
                    .middleMCP, .middlePIP, .middleDIP, .middleTip,
                    .ringMCP, .ringPIP, .ringDIP, .ringTip,
                    .littleMCP, .littlePIP, .littleDIP, .littleTip
                ]
                
                for joint in handJoints {
                    if let recognizedPoint = try? observation.recognizedPoint(joint),
                       recognizedPoint.confidence > 0.5 {
                        points.append(recognizedPoint.location)
                    }
                }
                
                DispatchQueue.main.async {
                    // Only convert points if we have a valid preview layer
                    if let previewLayer = self.previewLayer {
                        self.parent.bodyPoints = points.map { self.convertVisionPoint($0, previewLayer: previewLayer) }
                        self.parent.bodyPoseInfo = "Body detected with \(points.count) points"
                    }
                }
            }
        }
        
        request.maximumHandCount = 1
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Body pose detection failed: \(error)")
        }
    }
    
    // Convert Vision's normalized coordinates to screen coordinates
    func convertVisionPoint(_ point: CGPoint, previewLayer: AVCaptureVideoPreviewLayer) -> CGPoint {
        let screenSize = UIScreen.main.bounds.size
        let y = point.x * screenSize.height
        let x = point.y * screenSize.width
        return CGPoint(x: x, y: y)
    }
}
