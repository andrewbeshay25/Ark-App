//
//  User.swift
//  FirebaseTest
//
//  Created by Andrew Beshay on 1/23/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Codable{
    @DocumentID var id: String?
    var userFirstName: String
    var userLastName: String
    var userUID: String
    var userEmail: String
    var userRole: String
    var userPhoneNumber: String
    var userStreetAddress: String
    var userAptNumber: String
    var userCity: String
    var userState: String
    var userCountry: String
    var verified: Bool?
 
    enum CodingKeys: CodingKey{
        case userFirstName
        case userLastName
        case userUID
        case userEmail
        case userRole
        case userPhoneNumber
        case userStreetAddress
        case userAptNumber
        case userCity
        case userState
        case userCountry
        case verified
    }
}
struct DirectUser: Identifiable, Codable{
    @DocumentID var id: String?
    var userFirstName: String
    var userLastName: String
    var userUID: String
    var userEmail: String
    var userRole: String
    var userPhoneNumber: String
    var userStreetAddress: String
    var userAptNumber: String
    var userCity: String
    var userState: String
    var userCountry: String
 
    enum CodingKeys: CodingKey{
        case id
        case userFirstName
        case userLastName
        case userUID
        case userEmail
        case userRole
        case userPhoneNumber
        case userStreetAddress
        case userAptNumber
        case userCity
        case userState
        case userCountry
    }
}


