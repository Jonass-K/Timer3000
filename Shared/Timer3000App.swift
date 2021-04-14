//
//  Timer3000App.swift
//  Shared
//
//  Created by Jonas Kaiser on 22.03.21.
//

import SwiftUI

@main
struct Timer3000App: App {
    var body: some Scene {
        WindowGroup {
            Clock(model: ClockViewModel())
        }
    }
}
