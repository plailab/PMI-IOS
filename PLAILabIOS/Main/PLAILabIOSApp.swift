//
//  PLAILabIOSApp.swift
//  PLAILabIOS
//
//  Created by Xavier Nishikawa on 1/26/25.
//

import SwiftUI


@main // SAYS WHICH FILE TO START ON
struct PLAILabIOSApp: App {
    private var tokenService: TokenService = .init()

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(tokenService)
        }

    }
}
