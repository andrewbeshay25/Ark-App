//
//  ImageSlider.swift
//  TheApp
//
//  Created by Andrew Beshay on 8/25/22.
//

import SwiftUI

struct ImageSlider: View {
    
    private var numberOfPages = 1
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State private var currentIndex = 1
    
    
    var body: some View {
        GeometryReader{ proxy in
            TabView(selection: $currentIndex){
                
                Image("Jesus & St. Mary")
                    .resizable()
                    .scaledToFit()
                    .tag(1)
                
//                Image("Main Logo Design")
//                    .resizable()
//                    .scaledToFit()
//                    .tag(2)
//                
//                NavigationLink {
//                   //
//                } label: {
//                    Image("ChurchInfo")
//                        .resizable()
//                        .scaledToFit()
//                }
//                .tag(3)
                
            }.tabViewStyle(PageTabViewStyle())
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding()
                .frame(width: proxy.size.width, height: 250)
            
                .onReceive(timer, perform: { _ in
                    withAnimation {
                        currentIndex = currentIndex < numberOfPages ? currentIndex + 1 : 0
                    }
                })
        }
    }
}

struct ImageSlider_Previews: PreviewProvider {
    static var previews: some View {
        ImageSlider()
    }
}
