//
//  GoogleSignIn_Logic.swift
//  ARK
//
//  Created by Andrew Beshay on 7/24/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @AppStorage ("log_status") var logStatus: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    func signInWithGoogle() {
        Task {
            let success = await signInWithGoogleInternal()
            if success {
                await MainActor.run {
                    logStatus = true
                }
            }
        }
    }
    
    private func signInWithGoogleInternal() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            print("There is no root view controller!")
            return false
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken?.tokenString else {
                await setError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID token missing"]))
                return false
            }
            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            
            // Access available data from Google user object
            let googleUserProfile = user.profile
            let firstName = googleUserProfile?.givenName ?? ""
            let lastName = googleUserProfile?.familyName ?? ""
            let email = googleUserProfile?.email ?? ""
            let profilePictureURL = googleUserProfile?.imageURL(withDimension: 200)?.absoluteString ?? ""

            // Create a User object
            let appUser = User(
                id: firebaseUser.uid,
                userFirstName: firstName,
                userLastName: lastName,
                userUID: firebaseUser.uid,
                userEmail: email,
                userPhoneNumber: firebaseUser.phoneNumber ?? "",
                userStreetAddress: "",
                userAptNumber: "",
                userCity: "",
                userState: "",
                userCountry: "",
                userProfilePictureURL: profilePictureURL
            )
            
            // Save user data to Firestore
            try await Firestore.firestore().collection("Users").document(firebaseUser.uid).setData(from: appUser)
            
            // Save user to UserDefaults
            UserDefaults.standard.currentUser = appUser
            
            // Update log status on the main thread
            await MainActor.run {
                logStatus = true
            }
            
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
            return true
        } catch {
            await setError(error)
            return false
        }
    }
    
    // Logout function
        func logout() {
            do {
                try Auth.auth().signOut()
                clearUserDefaults()
                logStatus = false
            } catch {
                setError(error)
            }
        }
        
        private func clearUserDefaults() {
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "id")
            defaults.removeObject(forKey: "first_name")
            defaults.removeObject(forKey: "last_name")
            defaults.removeObject(forKey: "user_UID")
            defaults.removeObject(forKey: "user_Email")
            defaults.removeObject(forKey: "user_phoneNumber")
            defaults.removeObject(forKey: "user_address")
            defaults.removeObject(forKey: "user_apt")
            defaults.removeObject(forKey: "user_city")
            defaults.removeObject(forKey: "user_state")
            defaults.removeObject(forKey: "user_country")
            defaults.removeObject(forKey: "userProfilePictureURL")
            // Add any other keys that need to be cleared
        }
        
        private func setError(_ error: Error) {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.showError.toggle()
            }
        }
    }
