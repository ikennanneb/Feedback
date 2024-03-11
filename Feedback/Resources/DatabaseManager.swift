//
//  DatabaseManager.swift
//  Feedback
//
//  Created by Ikenna on 3/10/24.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager
{
    
    /// Shared instace of class
    public static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    private init() {}
    
    static func safeEmail(emailAddress: String) -> String
    {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

extension DatabaseManager
{
    /// Returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void)
    {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else
            {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

extension DatabaseManager
{
    /// Checks if user exists for given exists
    /// Parameters
    /// - `email`:             Target email to be checked
    /// - `completion`:  Async closure to return with result
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void))
    {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? [String : Any] != nil else
            {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    // Inserts new user to database
    public func insertUser(with user: FeedbackAppUser, completion: @escaping (Bool) -> Void)
    {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { [weak self] error, _ in
            
            guard let strongSelf = self else {return}
            
            guard error == nil else
            {
                print("Failed to write to database")
                completion(false)
                return
            }
            
            strongSelf.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                if var usersCollection = snapshot.value as? [[String: String]]
                {
                    // append to user dictionary
                    let newElement =
                    [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    strongSelf.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else
                        {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                        
                    })
                }
                else
                {
                    // create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    
                    strongSelf.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else
                        {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                        
                    })
                }
            })
        })
    }
    
    /// Gets all users from database
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void)
    {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else
            {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error
    {
        case failedToFetch
    }
    
}

struct FeedbackAppUser
{
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String
    {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
