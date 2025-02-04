// ScannerView.swift
import SwiftUI
import AVFoundation
import Vision

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
        
        // Store the preview layer in the coordinator
        context.coordinator.previewLayer = previewLayer
        Task {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update preview layer frame when view is resized
        context.coordinator.previewLayer?.frame = uiViewController.view.bounds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
