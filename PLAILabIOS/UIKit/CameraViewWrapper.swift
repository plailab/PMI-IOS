import Foundation
import SwiftUI
import AVFoundation
import Vision


// Needed for UIKit stuff so that it works with Swift
// UIkit is apples old framework, while swift ui is the newer one
// To use cameras most of the time, you will end up using ui kit
// because swift ui does not have the robust framework for it yet

// UI View vs UI View Controller
// UI View is something that the user can see
// UI View Controller is what actually organizes and controls the UI Views 
struct CameraViewWrapper: UIViewControllerRepresentable {
    var poseEstimator: PoseEstimator
    func makeUIViewController(context: Context) -> some UIViewController {
        let cvc = CameraViewController()
        cvc.delegate = poseEstimator
        return cvc
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
