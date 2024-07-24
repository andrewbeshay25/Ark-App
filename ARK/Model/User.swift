//
//  User.swift
//  FirebaseTest
//
//  Created by Andrew Beshay on 1/23/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var userFirstName: String
    var userLastName: String
    var userUID: String
    var userEmail: String
    var userPhoneNumber: String
    var userStreetAddress: String
    var userAptNumber: String
    var userCity: String
    var userState: String
    var userCountry: String
    var userProfilePictureURL: String?

    enum CodingKeys: CodingKey {
        case userFirstName
        case userLastName
        case userUID
        case userEmail
        case userPhoneNumber
        case userStreetAddress
        case userAptNumber
        case userCity
        case userState
        case userCountry
        case userProfilePictureURL
    }
}


extension UserDefaults {
    private enum Keys {
        static let currentUser = "currentUser"
    }
    
    var currentUser: User? {
        get {
            if let data = data(forKey: Keys.currentUser) {
                return try? JSONDecoder().decode(User.self, from: data)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                set(data, forKey: Keys.currentUser)
            } else {
                removeObject(forKey: Keys.currentUser)
            }
        }
    }
}


