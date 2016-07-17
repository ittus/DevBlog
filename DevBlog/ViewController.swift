//
//  ViewController.swift
//  DevBlog
//
//  Created by Minh Thang Vu on 7/16/16.
//  Copyright © 2016 Minh Thang Vu. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            performSegueWithIdentifier(SEGUE_LOGIN, sender: nil)
        }
    }
    @IBAction func btnFBLoginPressed(sender: UIButton) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"]) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError:NSError!) in
            if facebookError != nil {
                print("Facebook login error \(facebookError)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged with facebook \(accessToken)")
                
                let credentials = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                FIRAuth.auth()?.signInWithCredential(credentials, completion: { (user: FIRUser?, error: NSError?) in
                    if let errorEntity = error {
                        print("Login error \(errorEntity)")
                    } else {
                        print("Login success \(user)")
                        NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGIN, sender: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func attemptLogin(sender: UIButton) {
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user: FIRUser?, error: NSError?) in
                if error != nil {
                    if error?.code == FIRAuthErrorCode.ErrorCodeUserNotFound.rawValue {
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (createUser: FIRUser?, createError: NSError?) in
                            if let createErrorU = createError {
                                self.showErrorAlert("Could not create account", msg: createErrorU.description)
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(createUser?.uid, forKey: KEY_UID)
                                FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: nil)
                                self.performSegueWithIdentifier(SEGUE_LOGIN, sender: nil)
                            }
                        })
                    } else {
                        self.showErrorAlert("Error", msg: error!.description)
                    }
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                    self.performSegueWithIdentifier(SEGUE_LOGIN, sender: nil)

                }
            })
        } else {
            showErrorAlert("Email and Password required", msg: "You must enter email and password")
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

}

