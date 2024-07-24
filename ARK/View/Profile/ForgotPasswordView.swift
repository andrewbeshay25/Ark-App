//
//  ForgotPasswordView.swift
//  ARK
//
//  Created by Andrew Beshay on 7/24/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct ForgotPasswordView: View {
    
    @State private var emailID = ""
    
    @Binding var emailNotSent: Bool
    
    @State var isLoading: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    var body: some View {
        
        VStack (spacing: 15){
            Text("ENTER YOUR EMAIL ADDRESS")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $emailID)
                .customTextField(image: Image(systemName: "envelope.fill"))
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .accessibilityInputLabels([(Text("Element"))])
            
            Text("To reset your password, please enter your email address. You may need to check your spam folder.")
                .customFont(.caption)
            
            Button {
                isLoading = true
                resetPassword()
            } label: {
                HStack {
                    Image(systemName: "arrow.right")
                    Text(LocalizedStringKey("Send"))
                        .customFont(.headline)
                }
                .largeButton()
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Forgot Password")
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .alert(errorMessage, isPresented: $showError) {
            //
        }
    }
    
    func resetPassword(){
        Task{
            do{
                
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Email SENT")
                emailNotSent = false
                isLoading = false
            }catch{
                await setError(error)
            }
        }
    }
    
    func setError(_ error: Error)async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
    
}

#Preview {
    ForgotPasswordView(emailNotSent: .constant(false))
}
