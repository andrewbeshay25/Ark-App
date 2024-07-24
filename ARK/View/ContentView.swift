//
//  ContentView.swift
//  ARK
//
//  Created by Andrew Beshay on 7/17/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage ("log_status") var logStatus: Bool = false
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        if(logStatus){
            Text("Welcome")
            
            Button{
                authViewModel.logout()
            } label: {
                Text("Log Out")
            }
        } else{
            SignInView()
        }
    }
}

#Preview {
    ContentView()
}
