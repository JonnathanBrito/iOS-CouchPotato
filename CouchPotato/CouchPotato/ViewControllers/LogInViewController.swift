//
//  LogInViewController.swift
//  CouchPotato
//
//  Created by Jonnathan Brito on 11/17/20.
//

import UIKit
import SwiftKeychainWrapper

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var navBarLogIn: UINavigationBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
//        displayError(ErrorMessage: "Test")
        
        // Do any additional setup after loading the view.
        
        // MARK: - Hide Keyboard
//        let gestureRecognizer = UITapGestureRecognizer(target: self,
//                                     action: #selector(hideKeyboard))
//        gestureRecognizer.cancelsTouchesInView = false tableView.addGestureRecognizer(gestureRecognizer)
    }

    func setupElements(){
        navBarLogIn.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBarLogIn.shadowImage = UIImage()
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

    //MARK: - Back Button
//    @IBAction func backButtonTapped(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
    
    
    // MARK: - MAIN FUNCTION for Authorization
    @IBAction func loginTapped(_ sender: Any) {
        let error = FieldsCheck()
        if error != true{
            displayError(ErrorMessage: "Make sure all fields have been properly filled out.")
            return
        }
        else{
            let newUsername = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let newPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            getTokenRequest { (result) in
                let newToken = result?.token!
                print(newToken!)
                self.startSession(passedUsername: newUsername, passedPassword: newPassword, passedToken: newToken!) { (result) in
                    let validated = result?.success
                    if validated == true {
                        self.fetchSesssionId(passedToken: newToken!) { (result) in
                            let newSession = result?.session_id!
                            print(newSession!)
                            self.switchToMovieHub()
                        }
                    } else {
                        self.displayError(ErrorMessage: "Could not validate your credentials, please try again.")
                    }
                }
                
                
            }
           
            
        }
      
    }
    
    //MARK: - Checks fields to make sure that none are empty and returns true if they pass
    func FieldsCheck() -> Bool {
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return false
        }
        return true
    }
    
    

// MARK:- Error Message function, displayError
//https://www.youtube.com/watch?v=euf9c--areU&list=PLdW9lrB9HDw3bMSHtNZNt1Qb9XTMmQzLU&index=10&ab_channel=SergeyKargopolov
    
    func displayError(ErrorMessage : String) -> Void {
        DispatchQueue.main.async {
            let errorAltertController = UIAlertController(title: "Warning:", message: ErrorMessage, preferredStyle: .alert)
            let OkAction = UIAlertAction(title: "Ok", style: .default)
            {
                (action:UIAlertAction!) in DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                }
            }
            errorAltertController.addAction( OkAction)
            self.present(errorAltertController, animated: true, completion: nil)
            
     }
    }
    
// MARK:- Get Token Request and maintain the response for later use
    //https://stackoverflow.com/questions/62396033/tmdb-api-call-swift
    //Code has been modified for other API use
    
    func getTokenRequest (completion: @escaping(TokenRequest?) -> Void) {
            guard let url = URL(string: "https://api.themoviedb.org/3/authentication/token/new?api_key=5360dbcdd83554f5e5a36e56a57d32c8") else {
                fatalError("Invalid URL")
            }

                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)

                let task = session.dataTask(with: url) { data, response, error in

                    
                    guard error == nil else {
                        self.displayError(ErrorMessage: "The following error ocurred: \(error!)")
                        return
                    }
                    
                    guard let data = data else {
                        self.displayError(ErrorMessage: "There is no data")
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let movieDetails = try decoder.decode(TokenRequest.self, from: data)

                        DispatchQueue.main.async {
                            completion(movieDetails)

                        }
                      
                    
                    } catch let err {
                        self.displayError(ErrorMessage: "Err \(err)")
                    }
                }
                // execute the HTTP request
                task.resume()
                
            }
    
// MARK: - Fire Host API call to start session and request session ID
    
    func startSession(passedUsername: String, passedPassword: String, passedToken: String, completion: @escaping(SessionData?) -> Void) {
        guard let newUrl = URL(string: "https://api.themoviedb.org/3/authentication/token/validate_with_login?api_key=5360dbcdd83554f5e5a36e56a57d32c8") else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: newUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let JSONData = [ "username": passedUsername,
                         "password": passedPassword,
                         "request_token": passedToken,
                        ] as [String: String]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: JSONData, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayError(ErrorMessage: "Try Again")
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.displayError(ErrorMessage: "The following error ocurred: \(error!)")
                return
            }
            guard let data = data else {
                self.displayError(ErrorMessage: "There is no data")
                return
            }
            do {
                let decoder = JSONDecoder()
                let sessionDetails = try decoder.decode(SessionData.self, from: data)

                DispatchQueue.main.async {
                        completion(sessionDetails)

                }
            
            } catch let err {
                self.displayError(ErrorMessage: "Err \(err)")
            }
            
        }

        // execute the HTTP request
        task.resume()
    }
    
    
    //MARK: - fetchSesssionId, function to get a session ID to query data from User personal Database after Token has been validated
    func fetchSesssionId(passedToken: String, completion: @escaping(validatedSession?) -> Void) {
        guard let newUrl = URL(string: "https://api.themoviedb.org/3/authentication/session/new?api_key=5360dbcdd83554f5e5a36e56a57d32c8") else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: newUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let JSONData = [ "request_token": passedToken,
                        ] as [String: String]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: JSONData, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayError(ErrorMessage: "Try Again")
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.displayError(ErrorMessage: "The following error ocurred: \(error!)")
                return
            }
            guard let data = data else {
                self.displayError(ErrorMessage: "There is no data")
                return
            }
            do {
                let decoder = JSONDecoder()
                let validatedSessionDetails = try decoder.decode(validatedSession.self, from: data)

                DispatchQueue.main.async {
                        completion(validatedSessionDetails)

                }
            
            } catch let err {
                self.displayError(ErrorMessage: "Err \(err)")
            }
            
        }

        // execute the HTTP request
        task.resume()
    }
        
    //MARK: - switchToMovieHub, Programmatically Switch to next ViewController
    func switchToMovieHub() -> Void {
        let MovieHubViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? DisplayRecViewController
        view.window?.rootViewController = MovieHubViewController
        view.window?.makeKeyAndVisible()
    }
    
    
    
    //Hide Keyboard
//    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
//    let point = gestureRecognizer.location(in: tableView) let indexPath = tableView.indexPathForRow(at: point)
//    if indexPath != nil && indexPath!.section == 0
//    return
//    }
//    descriptionTextView.resignFirstResponder() }
    
}
