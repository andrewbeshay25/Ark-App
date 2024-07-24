//
//  SignInView.swift
//  ARK
//
//  Created by Andrew Beshay on 7/17/24.
//


import SwiftUI

import Firebase
import FirebaseFirestore
import GoogleSignIn
import FirebaseAuth

import iPhoneNumberField
import Combine


struct SignInView: View {
    @State var emailID = ""
    @State var password = ""
    
    @State var isLoading: Bool = false
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State private var showPassword: Bool = false

    @StateObject private var authViewModel = AuthViewModel()
    
    // User Defaults
    @AppStorage ("log_status") var logStatus: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign in")
                .customFont(.largeTitle)
                .foregroundColor(Color("Green"))
            Text("Welcome back!")
                .foregroundColor(Color("IAC"))
            
            VStack(alignment: .leading) {
                Text("Email")
                    .customFont(.subheadline)
                TextField("", text: $emailID)
                    .customTextField(image: Image(systemName: "envelope.fill"))
                //                    .foregroundColor(Color("Green"))
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .accessibilityInputLabels([(Text("Element"))])
            }
            VStack(alignment: .leading) {
                Text("Password")
                    .customFont(.subheadline)
                if showPassword {
                    TextField("Password", text: $password)
                        .customPasswordTextField(
                            image: Image(systemName: "lock.fill"),
                            eyeImage: Image(systemName: "eye.slash"),
                            showPassword: $showPassword
                        )
                } else {
                    SecureField("Password", text: $password)
                        .customPasswordTextField(
                            image: Image(systemName: "lock.fill"),
                            eyeImage: Image(systemName: "eye"),
                            showPassword: $showPassword
                        )
                }
                
            }
            Button("Forgot Password", action: {
                resetPassword()
            })
            .font(.callout)
            .foregroundColor(Color.gray)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, -10)
            .padding(.trailing, 5)
            
            Button {
                loginUser()
            } label: {
                HStack {
                    Image(systemName: "arrow.right")
                    Text(LocalizedStringKey("Sign in Button"))
                        .customFont(.headline)
                }
                .largeButton()
            }
            .disableWithOpacity(emailID == "" || password == "")
            
            HStack {
                Rectangle().frame(height: 1).opacity(0.1)
                Text("OR").customFont(.subheadline2).opacity(0.3)
                Rectangle().frame(height: 1).opacity(0.1)
            }
            
            Text("Sign In with Apple or Google")
                .customFont(.subheadline)
            
            Button(action: {
                authViewModel.signInWithGoogle()
            }) {
                Image("editedGoogle")
                    .resizable()
                    .frame(width: 75, height: 80)
            }
            
            
            VStack {
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                        .customFont(.subheadline)
                        .foregroundColor(Color("IAC"))
                    Button("Register Now", action: {
                        createAccount.toggle()
                    })
                    .foregroundColor(Color.accentColor)
                }
            }
        }
        .padding(30)
        .overlay(content: {
            LoadingView(show: $isLoading)
        }
        )
        .background(Color.secondary.opacity(0.3))
        .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color("Shadow").opacity(0.3), radius: 5, x: 0, y: 3)
        .shadow(color: Color("Shadow").opacity(0.3), radius: 30, x: 0, y: 30)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.linearGradient(colors: [Color.secondary, .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        
        .padding()
        .fullScreenCover(isPresented: $createAccount) {
            RegisterView()
        }
        .alert(errorMessage, isPresented: $showError) {
            //
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func loginUser(){
        isLoading = true
        Task{
            do{
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User FOUND")
                try await fetchUser()
            }catch{
                await setError(error)
            }
        }
    }
    
    // Fetch user
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        
        await MainActor.run {
            // Save the entire User object to UserDefaults
            UserDefaults.standard.currentUser = user
            
            // Update log status
            logStatus = true
        }
    }
    
    func resetPassword(){
        Task{
            do{
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Email SENT")
            }catch{
                await setError(error)
            }
        }
    }
    // Displaying errors with alerts
    func setError(_ error: Error)async{
        await MainActor.run(body: {
            errorMessage = "Incorrect email and/or password."
            showError.toggle()
            isLoading = false
            password = ""
        })
    }
}

// To fetch all countries and put USA at the top.
fileprivate struct Country {
    var id: String
    var name: String
    var color: Color
}
fileprivate func getLocales() -> [Country] {
    var locales = Locale.Region.isoRegions
        .compactMap { Country(id: $0.identifier, name: Locale.current.localizedString(forRegionCode: $0.identifier) ?? $0.identifier, color: Color(.red))}
    
    locales.sort { $0.name < $1.name } // Sort by name
    
    return [Country(id: "", name: "Select Country", color: Color("Golden"))] + [Country(id: "USA", name: Locale.current.localizedString(forRegionCode: "US") ?? "United States", color: Color("Golden"))] + locales
}


struct RegisterView: View{
    @State var firstName = ""
    @State var lastName = ""
    @State var phoneNumber = "N/A"
    @State var streetAddress = "N/A"
    @State var aptNumber = "N/A"
    @State var city = "N/A"
    @State var state = "N/A"
    @State var selectedCountry: String = "N/A"
    @State var emailID = ""
    @State var password = ""
    
    @State var isLoading = false
    @State private var showPassword: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    @StateObject private var authViewModel = AuthViewModel()

    // User Defaults
    @AppStorage ("log_status") var logStatus: Bool = false
    
    var body: some View{
        VStack(spacing: 20) {
            Text("Sign up")
                .customFont(.largeTitle)
                .foregroundColor(.accentColor)
            
            Text("Welcome to Ark!")
                .foregroundColor(Color("IAC"))
                .padding(.bottom, 10)
            
            ScrollView{
                VStack(spacing: 20){
                    Group{
                        HStack {
                            VStack(alignment: .leading) {
                                Text("First Name")
                                    .customFont(.subheadline)
                                TextField("", text: $firstName)
                                    .simpleCustomTextField()
                                    .frame(width: 145)
                                    .textContentType(.givenName)
                            }
                            VStack(alignment: .leading) {
                                Text("Last Name")
                                    .customFont(.subheadline)
                                TextField("", text: $lastName)
                                    .simpleCustomTextField()
                                    .frame(width: 145)
                                    .textContentType(.familyName)
                            }
                        }
                    }
                    
                    Group{
                        VStack(alignment: .leading) {
                            Text("Email")
                                .customFont(.subheadline)
                            TextField("", text: $emailID)
                                .autocapitalization(.none)
                                .customTextField(image: Image(systemName: "envelope.fill"))
                            //                                    .foregroundColor(Color("Green"))
                                .textContentType(.emailAddress)
                        }
                        VStack(alignment: .leading) {
                            Text("Password")
                                .customFont(.subheadline)
                            if showPassword {
                                TextField("Password", text: $password)
                                    .customPasswordTextField(
                                        image: Image(systemName: "lock.fill"),
                                        eyeImage: Image(systemName: "eye.slash"),
                                        showPassword: $showPassword
                                    )
                            } else {
                                SecureField("Password", text: $password)
                                    .customPasswordTextField(
                                        image: Image(systemName: "lock.fill"),
                                        eyeImage: Image(systemName: "eye"),
                                        showPassword: $showPassword
                                    )
                            }
                            
                            Text("Must be at least 6 characters long")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                        
                        
                        Button {
                            registerUser()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right")
                                Text(LocalizedStringKey("Sign up Button"))
                                    .customFont(.headline)
                            }
                            .largeButton()
                        }
                        .disableWithOpacity(
                            (
                                firstName == "" ||
                                lastName == "" ||
                                emailID == "" ||
                                password.count < 6
                            )
                        )
                    }
                    
                }
                .frame(width: 300)
                
                Group{
                    HStack {
                        Rectangle().frame(height: 1).opacity(0.1)
                        Text("OR").customFont(.subheadline2).opacity(0.3)
                        Rectangle().frame(height: 1).opacity(0.1)
                    }
                    
                    
                    Button(action: {
                        authViewModel.signInWithGoogle()
                    }) {
                        Image("editedGoogle")
                            .resizable()
                            .frame(width: 75, height: 80)
                    }
                    .padding(.top, -10)
                }
                .padding(.vertical, 10)
            }
            
            VStack{
                HStack {
                    Text("Already have an account?")
                        .customFont(.subheadline)
                    Button("Login Now", action: {
                        dismiss()
                    })
                    .foregroundColor(Color("Green"))
                }
            }
        }
        .alert(errorMessage, isPresented: $showError) {
            //
        }
        .padding(30)
        .background(Color.secondary.opacity(0.3))
        .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color("Shadow").opacity(0.3), radius: 5, x: 0, y: 3)
        .shadow(color: Color("Shadow").opacity(0.3), radius: 30, x: 0, y: 30)
        
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.linearGradient(colors: [Color.secondary, .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(content: {
            LoadingView(show: $isLoading)
        }
        )
        .padding()
        
    }
    
    func registerUser() {
        isLoading = true
        Task{
            do {
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                guard let userUID = Auth.auth().currentUser?.uid else { return }
                
                let user = User(
                    id: userUID,
                    userFirstName: firstName,
                    userLastName: lastName,
                    userUID: userUID,
                    userEmail: emailID,
                    userPhoneNumber: phoneNumber,
                    userStreetAddress: streetAddress,
                    userAptNumber: aptNumber,
                    userCity: city,
                    userState: state,
                    userCountry: selectedCountry
                )
                
                try await Firestore.firestore().collection("Users").document(userUID).setData(from: user)
                
                // Save user to UserDefaults
                UserDefaults.standard.currentUser = user
                logStatus = true
                print("User Created")
                
            } catch {
                try await Auth.auth().currentUser?.delete()
                await setError(error)
            }
            isLoading = false
        }
    }
    
    
    // Displaying errors with alerts
    func setError(_ error: Error)async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
            password = ""
        })
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
        //            .preferredColorScheme(.dark)
    }
}

struct PopoverContent: View {
    
    @Binding var popOverButton: Bool
    
    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()
            VStack {
                Text("Choose The Role That Best Fits You")
                    .customFont(.title3)
                    .padding()
                    .foregroundColor(Color("Golden"))
                Text("SERVANTS:")
                    .font(.headline)
                    .foregroundColor(Color("InverseAccentColor"))
                    .frame(width: 350, alignment: .leading)
                Text("If you are a servant in the church You will need verification to access specific features.\n\nTypically verification is given 1-3 days after signing up. If you do not see a verfied symbol on your profile page, please contact our development team through the app.")
                    .font(.subheadline)
                    .foregroundColor(Color("InverseAccentColor"))
                    .frame(width: 350)
                    .multilineTextAlignment(.leading)
                
                Button {
                    popOverButton.toggle()
                } label: {
                    Text(" Done")
                        .frame(width: 350, height: 50)
                        .foregroundColor(.accentColor)
                        .background(Color("Golden"))
                        .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .padding()
                }
                
                
            }
        }
        
    }
}

extension View{
    func disableWithOpacity(_ condition: Bool)-> some View{
        self
            .disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
}
