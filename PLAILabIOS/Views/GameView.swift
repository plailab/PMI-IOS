//
//  GameView.swift
//  PLAILabIOS
//
//  Created by Jack Wei on 2/23/25.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    let exercise: String

    var body: some View {
        switch exercise {
        case "Shoulder Raises":
            ShoulderRaiseGameView(poseEstimator: poseEstimator, size: size)
        case "Leg Raises":
            LegRaiseGameView(poseEstimator: poseEstimator, size: size)
        default:
            ShoulderRaiseGameView(poseEstimator: poseEstimator, size: size)
        }

    }

}
