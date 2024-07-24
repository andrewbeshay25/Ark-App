//
//  CustomTextField.swift
//
//  Created by Andrew Beshay.
//

import SwiftUI

struct CustomTextField: ViewModifier {
    var image: Image
    func body(content: Content) -> some View {
        content
            .padding(15)
            .padding(.leading, 36)
            .background(Color("Secondary").opacity(0.5))
            .mask(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(lineWidth: 1).fill(Color("IAC").opacity(0.3)))
            .overlay(image.frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 15))
        
    }
}

extension View {
    func customTextField(image: Image) -> some View {
        modifier(CustomTextField(image: image))
    }
}

struct SimpleCustomTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(15)
            .background(Color("Secondary").opacity(0.5))
            .mask(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(lineWidth: 1).fill(Color("IAC").opacity(0.3)))
    }
}
extension View {
    func simpleCustomTextField() -> some View {
        modifier(SimpleCustomTextField())
    }
}
struct TallCustomTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(15)
            .frame(height: 300)
            .background(Color("Golden").opacity(0.2))
            .mask(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(lineWidth: 1).fill(.black.opacity(0.1)))
            
    }
}
extension View {
    func tallCustomTextField() -> some View {
        modifier(TallCustomTextField())
    }
}

