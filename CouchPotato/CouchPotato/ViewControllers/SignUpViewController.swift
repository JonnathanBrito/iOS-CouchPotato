//
//  SignUpViewController.swift
//  CouchPotato
//
//  Created by Jonnathan Brito on 11/17/20.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var SignInNavBar: UINavigationBar!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sign In"
        
        setupElements()
        // Do any additional setup after loading the view.
    }
    

    
    func setupElements(){
        
        //sets the error message to transparent until there is a need for it
        SignInNavBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        SignInNavBar.shadowImage = UIImage()
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signupButton)
        
    }
    
    func validateFields() -> String? {
        
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
//        // Check if the password is secure
//        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        if Utilities.isPasswordValid(cleanedPassword) == false {
//            // Password isn't secure enough
//            return "Please make sure your password is at least 8 characters, contains a special character and a number."
//        }
        
        return nil
    }
    
    
    @IBAction func signUpTapped(_ sender: Any) {
    }
    
    

    

}
