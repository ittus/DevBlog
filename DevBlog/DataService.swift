//
//  DataService.swift
//  DevBlog
//
//  Created by Minh Thang Vu on 7/17/16.
//  Copyright © 2016 Minh Thang Vu. All rights reserved.
//

import Foundation
import Firebase


class DataService {
    static let ds = DataService()
    
    let FIR_BASE = FIRDatabase.database().reference()
    
    var REF_POSTS: FIRDatabaseReference {
        return FIR_BASE.child("posts")
    }
    
    var REF_USER: FIRDatabaseReference {
        return FIR_BASE.child("users")
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        self.REF_USER.child(uid).setValue(user)
    }
    
//    private var _REF_POSTS = FIR_BASE.child("posts")
//    private var _REF_USERS = FIR_BASE.child("users")
}