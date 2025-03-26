//
//  ExerciseGameView.swift
//  PLAILabIOS
//
//  Created by Jack Wei on 3/10/25.
//

// This serves as the abstract class template to follow for any future exersices

import SwiftUI

protocol ExerciseGameViewProtocol: View {
    var poseEstimator: PoseEstimator { get }
    var size: CGSize { get }

    // Define an associated type for the return type
    associatedtype Content: View

    // This function must be overridden in the conforming struct
    func createGameViewContent(geometry: GeometryProxy) -> Content
}
