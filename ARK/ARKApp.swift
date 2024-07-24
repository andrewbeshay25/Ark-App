//
//  ARKApp.swift
//  ARK
//
//  Created by Andrew Beshay on 7/17/24.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging


@main
struct ARKApp: App {
    @AppStorage ("log_status") var logStatus: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        application.registerForRemoteNotifications()

        // Check if the user is signed in and if their account exists in Firestore
                Auth.auth().addStateDidChangeListener { auth, user in
                    if let user = user {
                        Firestore.firestore().collection("Users").document(user.uid).getDocument { snapshot, error in
                            if let error = error {
                                // Error fetching user document
                                print("Error fetching user document: \(error.localizedDescription)")
                                return
                            }
                            
                            if let userData = snapshot?.data() {
                                // User document found
                                print("FOUND BRO")
                                
                                // Check if account is disabled
                                if let isDisabled = userData["disabled"] as? Bool, isDisabled {
                                    // Account exists but disabled
                                    print("ACCOUNT EXISTS BUT DISABLED")
                                    DispatchQueue.main.async {
                                        let alertController = UIAlertController(title: "Account Disabled", message: "Due to recent activity, your account has been disabled. Your information has not been deleted. If you think this is a mistake, contact the development team at application@virginmarybayonne.com.", preferredStyle: .alert)
                                        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                            UserDefaults.standard.set(false, forKey: "log_status")
                                        })
                                        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
                                    }
                                }
                                return
                            } else {
                                // User document not found
                                print("NOT FOUND BRO")
                                DispatchQueue.main.async {
                                    let alertController = UIAlertController(title: "Error Accessing Your Account", message: "There has been an error accessing your account. Try logging in again. If this is repeated, contact the development team at application@virginmarybayonne.com.", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                        UserDefaults.standard.set(false, forKey: "log_status")
                                    })
                                    UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
                                }
                                return
                            }
                        }
                    } else {
                        // User is logged out
                        print("LOGGED OUT BRO")
                        return
                    }
                }
        return true
    }

    
    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Oh no! Failed to register for remote notifications with error \(error)")
    }
    
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var readableToken = ""
        for index in 0 ..< deviceToken.count {
            readableToken += String(format: "%02.2hhx", deviceToken[index] as CVarArg)
        }
        print("Received an APNs device token: \(readableToken)")
        
        // Now that we have the APNS token, we can fetch the FCM token
        Messaging.messaging().token { token, error in
            if let error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token {
                print("FCM registration token: \(token)")
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {
    @objc func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase token is: \(String(describing: fcmToken))")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .list, .sound]])
    }
    
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        
        completionHandler()
    }
}
