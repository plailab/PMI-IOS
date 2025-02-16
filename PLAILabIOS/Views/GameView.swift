//
//  GameView.swift
//  PLAILabIOS
//
//  Created by Jack Wei on 2/16/25.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    var body: some View {
        if poseEstimator.bodyParts.isEmpty == false {
            ZStack {
                Image("pacman") // Switch images based on the condition
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                .position(inversePoint(poseEstimator.bodyParts[.leftWrist]!.location, in: size))
                
                Image("pacman") // Switch images based on the condition
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                .position(inversePoint(poseEstimator.bodyParts[.rightWrist]!.location, in: size))
                
            }
        }
    }
}
