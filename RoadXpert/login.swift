//
//  Start.swift
//  RoadXpert
//
//  Created by Chelsey Bergmann on 12/28/20.
//

import Foundation
import UIKit
import Firebase

class Login: UIViewController {
//    var handle = Auth.auth()
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var welcomeBack: UILabel!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var errorMessage: UILabel!

    var signIn = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "Start", sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      
    }
    /*
     Log in user and advance to record/all trips scene.
     */
    @IBAction func signIn(_ sender: Any) {
            if signIn { // Sign In.
                Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { (authResult, error) in
                    if let error = error as? NSError {
                        self.view.endEditing(true)
                        switch AuthErrorCode(rawValue: error.code) {
                        case .operationNotAllowed:
                          // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
                            self.errorMessage.text = "Email and passwords not enabled."
                        case .userDisabled:
                          // Error: The user account has been disabled by an administrator.
                            self.errorMessage.text = "This account is disabled."
                        case .wrongPassword:
                          // Error: The password is invalid or the user does not have a password.
                            self.errorMessage.text = "Password is incorrect."
                        case .invalidEmail:
                          // Error: Indicates the email address is malformed.
                            self.errorMessage.text = "The email is badly formatted."
                        default:
                            print("Error: \(error.localizedDescription)")
                            self.errorMessage.text = "Incorrect email or password."
                        }
                  } else {
                    print("User signs in successfully")
                    let userInfo = Auth.auth().currentUser
                    let email = userInfo?.email
                  
                    self.performSegue(withIdentifier: "Start", sender: nil)
                  }
                }
                } else {
                    signUp()
                }
    }
            

    /*
     Controls the instructions on screen for this login or signup of user.
     */
    @IBAction func signInOrUp(_ sender: Any) {
        // Sign in -> Sign up
        if welcomeBack.text == "Welcome back" {
            welcomeBack.text = "Create an account"
            question.text = "Already have an account?"
            button.setTitle("Sign in", for: .normal)
            signIn = false
            
        // Sign up back to sign in
        } else {
            welcomeBack.text = "Welcome back"
            question.text = "Don't have an account?"
            button.setTitle("Sign up", for: .normal)
            signIn = true
        }
    }
            

    /*
    Create new account.
    */
    func signUp() {
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { authResult, error in
          if let error = error as? NSError {
            self.view.endEditing(true)
            switch AuthErrorCode(rawValue: error.code) {
            case .operationNotAllowed:
              // Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
                print("Email/password is disabled")
            case .emailAlreadyInUse:
              // Error: The email address is already in use by another account.
                self.errorMessage.text = "There is already an account with this email."
            case .invalidEmail:
              // Error: The email address is badly formatted.
                self.errorMessage.text = "The email is badly formatted."
            case .weakPassword:
              // Error: The password must be 6 characters long or more.
                self.errorMessage.text = "Password must be at least 6 characters."
            default:
                print("Error: \(error.localizedDescription)")
                self.errorMessage.text = error.localizedDescription
            }
          } else {
            print("User signs up successfully")
            let newUserInfo = Auth.auth().currentUser
            let email = newUserInfo?.email
            self.performSegue(withIdentifier: "Start", sender: nil)
          }
        }
    }
}

class StartRecords: UIViewController {
}

