//
//  ViewController.swift
//  CouchPotato
//
//  Created by Jonnathan Brito on 11/16/20.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var skipButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupElements()
//        getMovieDetails(movie: 150) { (result) in
//            print("finished")
//        }
//        getFavMovies { (results) in
//            print("worked")
//        }
//        print("finished")
        

    }

    func setupElements(){
        Utilities.styleHollowButton(loginButton)
        Utilities.styleHollowButton(skipButton)
    }
    
// MARK: - Add Hide Keyboard Functionality
    
    
    
    
    
    func getMovieDetails(movie: Int, completion: @escaping (RESULT?) -> ()) {

            guard let url = URL(string: "https://api.themoviedb.org/3/movie/157336?api_key=5360dbcdd83554f5e5a36e56a57d32c8") else {
                fatalError("Invalid URL")
            }

                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)

                let task = session.dataTask(with: url) { data, response, error in

                    // Check for errors
                    guard error == nil else {
                        print ("error: \(error!)")
                        return
                    }
                    // Check that data has been returned
                    guard let data = data else {
                        print("No data")
                        return
                    }

                    do {

                        let decoder = JSONDecoder()
                        let movieDetails = try decoder.decode(RESULT.self, from: data)

                        DispatchQueue.main.async {

                           completion(movieDetails)
                            print(movieDetails)

                        }

                    } catch let err {
                        print("Err", err)
                    }
                }
                // execute the HTTP request
                task.resume()
            }
    func getMoviesTest() {

            guard let url = URL(string: "https://api.themoviedb.org/3/movie/550?api_key=5360dbcdd83554f5e5a36e56a57d32c8") else {
                fatalError("Invalid URL")
            }

                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)

                let task = session.dataTask(with: url) { data, response, error in

                    // Check for errors
                    guard error == nil else {
                        print ("The following error ocurred: \(error!)")
                        return
                    }
                    // Check that data has been returned
                    guard let data = data else {
                        print("There is no data")
                        return
                    }

                    do {

                        let decoder = JSONDecoder()
                        let movieDetails = try decoder.decode(RESULT.self, from: data)

                        DispatchQueue.main.async {
                            print(movieDetails)

                        }

                    } catch let err {
                        print("Err", err)
                    }
                }
                // execute the HTTP request
                task.resume()
            }
        }

        



//    @IBAction func SkipTapped(_ sender: Any) {
//
//    }
//}

