//
//  MatchedView.swift
//  AnimatedApp
//
//  Created by Andrew Beshay on 7/29/22.
//

import SwiftUI

struct CardView: View {
    @Namespace var namespace
    @State var show = false
    var item: Primary
    
    var body: some View {
        ZStack{
            if !show{
                VStack{
                    Spacer()
                    VStack(alignment: .leading, spacing: 12){
                        item.title
                            .customFont(.title2)
                            .matchedGeometryEffect(id: "title", in: namespace)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .layoutPriority(2)
                        item.subtitle
                            .opacity(0.7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .matchedGeometryEffect(id: "subtitle", in: namespace)
                    }
                    .padding(20)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                            .blur(radius: 30)
                            .matchedGeometryEffect(id: "blur", in: namespace)
                        
                    )
                    
                }
                .foregroundColor(.white)
                .background(
                    Image("Spline")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: "image", in: namespace)
                )
                
                .background(.linearGradient(colors: [item.color.opacity(1), item.color.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .matchedGeometryEffect(id: "mask", in: namespace))
                .frame(width: 300, height: 300)
                .padding(20)
            }
            else{
                ScrollView {
                    VStack{
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 500)
                    .foregroundStyle(.black)
                    .background(
                        Image("Spline")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .matchedGeometryEffect(id: "image", in: namespace)
                    )
                    
                    
                    .mask(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .matchedGeometryEffect(id: "mask", in: namespace)
                    )
                    
                    .overlay(
                        VStack(alignment: .leading, spacing: 12){
                            
                            item.title
                                .customFont(.title2)
                                .matchedGeometryEffect(id: "title", in: namespace)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .layoutPriority(1)
                            
                            item.caption
                                .opacity(0.7)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .matchedGeometryEffect(id: "subtitle", in: namespace)
                            
                        }
                            .padding(20)
                            .background(
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                                    .matchedGeometryEffect(id: "blur", in: namespace)
                                
                            )
                        
                            .offset(y: 250)
                            .padding(20)
                        
                    )
                }
                .background(Color("InverseAccentColor"))
                .ignoresSafeArea()
                
                Button{
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)){
                        show.toggle()
                    }
                }label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.bold))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                    
                }
                .frame(maxWidth: .infinity, maxHeight: 650, alignment: .topTrailing)
                .padding(20)
                .ignoresSafeArea()
            }
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(item: primaries[2])
    }
}
