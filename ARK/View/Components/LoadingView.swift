//
//  LoadingView.swift
//  FirebaseTest
//
//  Created by Andrew Beshay on 2/22/23.
//

import SwiftUI

struct LoadingView: View {
    @Binding var show: Bool
    var body: some View {
        
        ZStack{
            if show{
                Group{
                    Rectangle()
                        .fill(Color("IAC").opacity(0.25))
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .padding()
                        .background(Color.accentColor,in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.25), value: show)
    }
}
