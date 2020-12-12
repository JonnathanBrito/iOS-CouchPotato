//
//  DisplayRecViewController.swift
//  CouchPotato
//
//  Created by Jonnathan Brito on 11/25/20.
//

import UIKit
import SwiftKeychainWrapper



class DisplayRecViewController: UIViewController {
 
    
//    var moveSessionHere: String = ""
//    weak var delegate: CredentialsFromLoginDelegate?
    
//    print(moveSessionHere)
    
    
    var average:Double = 0
    var Counter:Int = 0
    var Movie_ID:Int = 0
    let SessionToken: String? = KeychainWrapper.standard.string(forKey: "SessionToken")
    let usernmame: String? = KeychainWrapper.standard.string(forKey: "Username")
    
    @IBOutlet weak var MoviesHubNavBar: UINavigationBar!

    @IBOutlet weak var PosterImage: UIImageView!
    
    @IBOutlet weak var TitleLable: UILabel!
    
    @IBOutlet weak var DateLable: UILabel!
    
    @IBOutlet weak var PopularityLabel: UILabel!
    
    @IBOutlet weak var RatingLabel: UILabel!
    
    @IBOutlet weak var LangaugeLabel: UILabel!
    
    @IBOutlet weak var DescriptionLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MoviesHubNavBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        MoviesHubNavBar.shadowImage = UIImage()
        let newListofFavMovies = FavMovieRequest()
        newListofFavMovies.getFavMovies { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let Movies):
                var total: Double = 0.0
                for index in 0..<Movies.count {
                    total = total + Movies[index].vote_average
                }
                let local_avg = total / Double(Movies.count)
                self!.average = Double(round(10*local_avg)/10)
                
                //MARK: - Call of Recommendation Function and end of data collection

                self!.displayRecommendation()
            }
        }
    }

    
    
    //MARK: - MAIN FUNCTION: Want app to run without being prompted to do so
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    //MARK: - Signs out. BUG: Pages after aren't solid until you sign in again
    @IBAction func SignOutButtonTapped(_ sender: Any) {
        print("Button Tapped")
        KeychainWrapper.standard.remove(forKey: "SessionToken")
        KeychainWrapper.standard.remove(forKey: "Username")
        let restartPage = storyboard?.instantiateViewController(identifier: "Welcome") as? ViewController
        view.window?.rootViewController = restartPage
        view.window?.makeKeyAndVisible()
    }
    
    
    
    @IBAction func LibraryButtonTapped(_ sender: Any) {
//        let vc = MoviesTableViewController()
        
    }
    
    
    @IBAction func addFavoriteButtonTapped(_ sender: Any) {
        addToFavoritesFunction()
        Counter += 1
        displayRecommendation()
    }
    
    
    func addToFavoritesFunction() {
        guard let newUrl = URL(string: "https://api.themoviedb.org/3/account/1/favorite?api_key=5360dbcdd83554f5e5a36e56a57d32c8&session_id=\(SessionToken!)") else {
        fatalError("Invalid URL")
        }
        var request = URLRequest(url: newUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let JSONData = [ "media_type": "movie",
                         "media_id": String(Movie_ID),
                         "favorite": "true",
                        ] as [String: String]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: JSONData, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayError(ErrorMessage: "Try Again Please")
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.displayError(ErrorMessage: error.debugDescription)
                return
            }
            guard let data = data else {
                print("NO Data")
                return
            }
            do {
                let decoder = JSONDecoder()
                let sessionDetails = try decoder.decode(SessionData.self, from: data)
                DispatchQueue.main.async {
                    print("Successful addition \(sessionDetails.status_code!)")
                }
            } catch let err {
                self.displayError(ErrorMessage: err.localizedDescription)
            }
        }
        // execute the HTTP request
        task.resume()
        }


    
    @IBAction func SkipButtonTapped(_ sender: Any) {
        Counter += 1
        displayRecommendation()
    }
    
    
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
    
    
    //MARK: - MAIN FUNCTION FOR GETTING RECOMMENDATIONS, Basically a Duplicate of get Favorite Movies

        func getRecommendations(completion: @escaping(Result<[Resultsinfo], FavMovieError>) -> Void) {
            let attempt_url = "https://api.themoviedb.org/3/discover/movie?api_key=5360dbcdd83554f5e5a36e56a57d32c8&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&vote_average.gte=\(average)"
            guard let url = URL(string: attempt_url)
            else {
                
                fatalError("Invalid URL")
            }
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(.failure(.UrlRequest))
                return
            }
            
            guard let newData = data else {
                completion(.failure(.NoData))
                return
            }
            do {
                
                let decoder = JSONDecoder()
                let movieDetails = try decoder.decode(FavMovieInfo.self, from: newData)
                let favMoviedata = movieDetails.results
                completion(.success(favMoviedata))
                } catch {
                completion(.failure(.CantProcess))
                }
            }
        task.resume()
        }
    
    //MARK: - Function to display singular return from Recommendation call
    
    //MARK:- Error, page starts in the same movie rec with only a few criteria
    func displayRecommendation() {
        self.getRecommendations { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let Recommendations):
                self!.Movie_ID = Recommendations[self!.Counter].id
                //MARK: - Code to fetch image for poster
                let url_string:String = "https://image.tmdb.org/t/p/w185\(Recommendations[self!.Counter].poster_path)"
                guard let url = URL(string: url_string) else {
                    print("Does not have a String or did not work")
                    return
                }
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                let task = session.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    print("Error: \(error.debugDescription)")
                    return
                }
                guard data != nil else {
                    print("No data")
                    return
                }
                //MARK: - Start of Page element declarations
                let poster = UIImage(data: data!)
                DispatchQueue.main.async {
                    self!.PosterImage.image = poster
                    let newTitle:String = Recommendations[self!.Counter].title
                    self!.TitleLable.text = "Title: \(newTitle)"
                    let newDate:String = Recommendations[self!.Counter].release_date
                    self!.DateLable.text = "Date Released: \(newDate)"
                    let newAverage:String = String(Recommendations[self!.Counter].vote_average)
                    self!.RatingLabel.text = "Average Rating: \(newAverage)"
                    let newPopularity:String = String(Recommendations[self!.Counter].popularity)
                    self!.PopularityLabel.text = "Popular Among: \(newPopularity) people"
                    let newLangauge:String = Recommendations[self!.Counter].original_language
                    self!.LangaugeLabel.text = "Original Langauge: \(newLangauge)"
                    let newDescription:String = Recommendations[self!.Counter].overview
                    self!.DescriptionLabel.text = newDescription
                }
            }

        
        task.resume()
        }
        }
    }
    
    func updateRecommendations(){
        
    }
    

    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
