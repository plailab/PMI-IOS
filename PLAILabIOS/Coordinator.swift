// Coordinator.swift
import AVFoundation
import Vision
import UIKit

class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var parent: ScannerView
    var previewLayer: AVCaptureVideoPreviewLayer?
    
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
        let request = VNDetectHumanHandPoseRequest { [weak self] (request, error) in
            guard let self = self,
                  let observations = request.results as? [VNHumanHandPoseObservation],
                  !observations.isEmpty else {
                DispatchQueue.main.async {
                    self?.parent.handPoseInfo = "No hand detected"
                    self?.parent.handPoints = []
                }
                return
            }
            
            if let observation = observations.first {
                var points: [CGPoint] = []
                
                let handJoints: [VNHumanHandPoseObservation.JointName] = [
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
                        self.parent.handPoints = points.map { self.convertVisionPoint($0, previewLayer: previewLayer) }
                        self.parent.handPoseInfo = "Hand detected with \(points.count) points"
                    }
                }
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
    func convertVisionPoint(_ point: CGPoint, previewLayer: AVCaptureVideoPreviewLayer) -> CGPoint {
        let screenSize = UIScreen.main.bounds.size
        let y = point.x * screenSize.height
        let x = point.y * screenSize.width
        return CGPoint(x: x, y: y)
    }
}
