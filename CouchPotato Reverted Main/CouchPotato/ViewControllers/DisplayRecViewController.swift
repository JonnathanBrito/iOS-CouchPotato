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
    
    
    let SessionToken: String? = KeychainWrapper.standard.string(forKey: "SessionToken")
    let usernmame: String? = KeychainWrapper.standard.string(forKey: "Username")
    
    var FavMoviesToDisplay = [Resultsinfo]()
    var FavMoviesLibrary = [Resultsinfo]()
    
    //To track number of iterations through the array with limit of 10
    var totalCounter:Int = 0
    var Counter:Int = 0
    
    var Average:String = ""
    var Movie_ID:String = ""
    var Title:String = ""
    var Popularity:String = ""
    var Langauge:String = ""
    var Description:String = ""
    var Poster_Path:String = ""
    var Date:String = ""
    
    var RecommendedAverage:String = ""
    var RecommendedPopularity:String = ""
    var RecommendedDate:String = ""
    var RecommendedLanguage:String = ""
    
    var favorited:Bool = false

    
    @IBOutlet weak var MoviesHubNavBar: UINavigationBar!

    @IBOutlet weak var PosterImage: UIImageView!
    
    @IBOutlet weak var TitleLable: UILabel!
    
    @IBOutlet weak var DateLable: UILabel!
    
    @IBOutlet weak var PopularityLabel: UILabel!
    
    @IBOutlet weak var RatingLabel: UILabel!
    
    @IBOutlet weak var LangaugeLabel: UILabel!
    
    @IBOutlet weak var DescriptionLabel: UILabel!
    
    
    
    //MARK:- First call to getFavMovies to set global array values to not have to repeatedly run the same API
    override func viewDidLoad() {
        super.viewDidLoad()
        MoviesHubNavBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        MoviesHubNavBar.shadowImage = UIImage()
        //Gets Favorited Movies
        let newListofFavMovies = FavMovieRequest()
        newListofFavMovies.getFavMovies { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let Movies):
                self?.FavMoviesLibrary = Movies
                //Just to have something in there
                self?.FavMoviesToDisplay = Movies
                //MARK: - Call of Recommendation Function and end of data collection
                self!.RecommendationAlgorithm()
                
                //MARK: - Call to Recommendation Function to use gathered data and saves data in global array of Results
                self!.getRecommendations()
                
                //MARK: - Call display function for first recommended movie
                self!.displayRecommendation()
            }
        }
    }

    

    //MARK: - Signs out. BUG: Pages after aren't solid until you sign in again
    @IBAction func SignOutButtonTapped(_ sender: Any) {
        KeychainWrapper.standard.remove(forKey: "SessionToken")
        KeychainWrapper.standard.remove(forKey: "Username")
        let restartPage = storyboard?.instantiateViewController(identifier: "Welcome") as? ViewController
        view.window?.rootViewController = restartPage
        view.window?.makeKeyAndVisible()
    }
    
    
    
    //MARK: - Like Button Tapped to fire off Add To Favorites Function with API
    @IBAction func addFavoriteButtonTapped(_ sender: Any) {
        Counter = 0
        favorited = true
        //Adds favorite to library of favorites
        addToFavoritesFunction()
        //Updates the global library of favorites as the array of gloabl variables
        updateLibraryofFavorites()
        let Random = Bool.random()
        if Random {
            recommendedMovies()
        }
        else {
            similarMovies()
        }
//        //runs algorithm with new library
//        RecommendationAlgorithm()
//        //calls recommendation function and updates the global array of Results containing recommendations
//        getRecommendations()
        
        
        //displays first instance of new recommendation list
        displayRecommendation()
    }
    


    //MARK: - Skipp Button, iterates through array and displays next Movie Recommendation
    @IBAction func SkipButtonTapped(_ sender: Any) {
        totalCounter += 1
        if favorited {
            switch Counter {
            case 3:
                Counter = 0
                RecommendationAlgorithm()
                getRecommendations()
                displayRecommendation()
                favorited = false
            default:
                Counter += 1
                displayRecommendation()
            }
        }
        else if (totalCounter > 12){
            var newDate:Int = Int(self.RecommendedDate) ?? 0
            // This is faulty but I think it helps a lot since too many highly rated movies are recent for me at least.
            newDate -= 1
            self.RecommendedDate = String(newDate)
            totalCounter = 0
            getRecommendations()
            displayRecommendation()
        }
            
        else if Counter == 8 {
            Counter = 0
            getRecommendations()
            displayRecommendation()
            } else {
                Counter += 1
                displayRecommendation()
        }
    }
    
    
    //MARK: - Display Errors Notices to User prompting repsonse OK
    
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
    
    //MARK:- END OF IBACTION FUNCTIONALITY
    
    
    
    //MARK: - START OF BACKEND FUNCTION IMPLEMENTATION
    
    
    //MARK: - Recommendations Algorithm
    func RecommendationAlgorithm(){
        //MARK:- Average of all Rating and Year
        var vote_total: Double = 0.0
        //Could do this to go through all data but recent information is more valuable than old data but this can be changed and adjusted easily with switch cases
//        for index in 0..<FavMoviesLibrary.count
        var MaxIterations:Int = 0
        if FavMoviesLibrary.count <= 6 {
            MaxIterations = FavMoviesLibrary.count
        }
        else {
            MaxIterations = 5
        }
        var date:String = ""
        var dateTotal:Int = 0
        for index in 0..<MaxIterations {
            vote_total += FavMoviesLibrary[index].vote_average
            date =  FavMoviesLibrary[index].release_date
            date.removeLast(6)
            dateTotal += Int(date) ?? 0
            }
        let local_avg = vote_total / Double(FavMoviesLibrary.count)
        self.RecommendedAverage = String(Double(round(10*local_avg)/10))
        let avgDate:Int = dateTotal/MaxIterations
        self.RecommendedDate = String(avgDate)
        print("Average Date: \(avgDate)")

    }
    
    
    
    
    
    //MARK: - MAIN FUNCTIONS FOR GETTING RECOMMENDATIONS
    
    //MARK: - TMDB provided Recommendations API
    func recommendedMovies() {
        let attempt_url = "https://api.themoviedb.org/3/movie/\(Movie_ID)/recommendations?api_key=5360dbcdd83554f5e5a36e56a57d32c8&language=en-US&page=1"
        guard let url = URL(string: attempt_url)
        else {

            fatalError("Invalid URL")
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { data, response, error in
        guard error == nil else {
            print("error getting the session")
            return
        }

        guard let newData = data else {
            print("no data")
            return
        }
        do {

            let decoder = JSONDecoder()
            let movieDetails = try decoder.decode(FavMovieInfo.self, from: newData)
            let favMoviedata = movieDetails.results
            self.FavMoviesToDisplay = favMoviedata
            } catch {
                print(error.localizedDescription)
            }
        }
    task.resume()
    }
    
    //MARK:- TMBI Porovided Call for similar Movies
    
    func similarMovies() {
        let attempt_url = "https://api.themoviedb.org/3/movie/\(Movie_ID)/similar?api_key=5360dbcdd83554f5e5a36e56a57d32c8&language=en-US&page=1"
        guard let url = URL(string: attempt_url)
        else {

            fatalError("Invalid URL")
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { data, response, error in
        guard error == nil else {
            print("error getting the session")
            return
        }

        guard let newData = data else {
            print("no data")
            return
        }
        do {

            let decoder = JSONDecoder()
            let movieDetails = try decoder.decode(FavMovieInfo.self, from: newData)
            let favMoviedata = movieDetails.results
            self.FavMoviesToDisplay = favMoviedata
            } catch {
                print(error.localizedDescription)
            }
        }
    task.resume()
    }
    
    

    
    
    //MARK: - Recommendation based only on Date and Average
        func getRecommendations() {
            let attempt_url = "https://api.themoviedb.org/3/discover/movie?api_key=5360dbcdd83554f5e5a36e56a57d32c8&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&year=\(RecommendedDate)&vote_average.gte=\(RecommendedAverage)"
            guard let url = URL(string: attempt_url)
            else {

                fatalError("Invalid URL")
            }
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("error getting the session")
                return
            }

            guard let newData = data else {
                print("no data")
                return
            }
            do {

                let decoder = JSONDecoder()
                let movieDetails = try decoder.decode(FavMovieInfo.self, from: newData)
                let favMoviedata = movieDetails.results
                self.FavMoviesToDisplay = favMoviedata
                } catch {
                    print(error.localizedDescription)
                }
            }
        task.resume()
        }
    
    
    //MARK: - Recommendation based only on Date
        func getRecommendationsDate() {
            let attempt_url = "https://api.themoviedb.org/3/discover/movie?api_key=5360dbcdd83554f5e5a36e56a57d32c8&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&year=\(RecommendedDate)"
            guard let url = URL(string: attempt_url)
            else {

                fatalError("Invalid URL")
            }
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("error getting the session")
                return
            }

            guard let newData = data else {
                print("no data")
                return
            }
            do {

                let decoder = JSONDecoder()
                let movieDetails = try decoder.decode(FavMovieInfo.self, from: newData)
                let favMoviedata = movieDetails.results
                self.FavMoviesToDisplay = favMoviedata
                } catch {
                    print(error.localizedDescription)
                }
            }
        task.resume()
        }
    
    //MARK: - Recommendation based only on Rating averages
    
    func getRecommendationsRatings() {
        let attempt_url = "https://api.themoviedb.org/3/discover/movie?api_key=5360dbcdd83554f5e5a36e56a57d32c8&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&vote_average.gte=\(RecommendedAverage)"
        guard let url = URL(string: attempt_url)
        else {

            fatalError("Invalid URL")
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { data, response, error in
        guard error == nil else {
            print("error getting the session")
            return
        }

        guard let newData = data else {
            print("no data")
            return
        }
        do {

            let decoder = JSONDecoder()
            let movieDetails = try decoder.decode(FavMovieInfo.self, from: newData)
            let favMoviedata = movieDetails.results
            self.FavMoviesToDisplay = favMoviedata
            } catch {
                print(error.localizedDescription)
            }
        }
    task.resume()
    }
   
    
    //MARK: - Updates the global variables and sets the labels and UI image to updated data w/ API to fetch image data
    func displayRecommendation(){
        //Hard Coded a fix to an error where it would attempt to read the data for FavMoviestoDisplay before there was anything there, and then it would display the first instance of your library, but only the first time. Other solution was to add a completion handler but running low on time I just did this. 
        if totalCounter == 0 {
            Counter += 1
        }
        
        //RUN CODE TO CHECK IF ID IS IN LIBRARY, more effiecinet response to above issue
        print("Total Counter: \(totalCounter)")
//        while duplicate(){
//            totalCounter += 1
//            if Counter != 8{
//                Counter += 1
//            }
//            else {
//                Counter = 0
//                if(totalCounter == 20){
//                    var newDate:Int = Int(self.RecommendedDate) ?? 0
//                    // This is faulty but I think it helps a lot
//                    newDate -= 1
//                    self.RecommendedDate = String(newDate)
//                    totalCounter = 0
//                }
//                else {
//                RecommendationAlgorithm()
//                }
//                getRecommendations()
//            }
//        }
        //MARK: - Above leads to infinite loop
        //TEST PURPOSES
        print("Counter: \(Counter)")
        // - Start of Poster element declarations
        self.Title = FavMoviesToDisplay[self.Counter].title
        self.Popularity = String(FavMoviesToDisplay[self.Counter].popularity)
        self.Movie_ID = String(FavMoviesToDisplay[self.Counter].id)
        self.Langauge = FavMoviesToDisplay[self.Counter].original_language
        self.Description = FavMoviesToDisplay[self.Counter].overview
        self.Poster_Path = FavMoviesToDisplay[self.Counter].poster_path
        self.Date = FavMoviesToDisplay[self.Counter].release_date
        self.Average = String(FavMoviesToDisplay[self.Counter].vote_average)
        let url_string:String = "https://image.tmdb.org/t/p/w185\(Poster_Path)"
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
            // - Start of Poster element declarations
            let Poster_URL = UIImage(data: data!)
            DispatchQueue.main.async {
                self.PosterImage.image = Poster_URL
                self.TitleLable.text = "Title: \(self.Title)"
                self.DateLable.text = "Date Released: \(self.Date)"
                self.RatingLabel.text = "Average Rating: \(self.Average)"
                self.PopularityLabel.text = "Popular Among: \(self.Popularity) people"
                self.LangaugeLabel.text = "Original Langauge: \(self.Langauge)"
                self.DescriptionLabel.text = self.Description
            }
        }
        task.resume()
    }
    
    //MARK:- Adds Movie to Favorites using global variable Movie_ID to identify movie
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
        task.resume()
    }
    
    func updateLibraryofFavorites(){
        let newListofFavMovies = FavMovieRequest()
        newListofFavMovies.getFavMovies { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let Movies):
                self!.FavMoviesLibrary = Movies
                print("Favorites List has been updated")
            }
        }
    }
    
    
    //MARK:- Causes infinte loop
    func duplicate() -> Bool {
        for index in 0..<FavMoviesLibrary.count {
            if Movie_ID == String(FavMoviesLibrary[index].id) {
                return true
            }
        }
        return false
    }
    
    

    //MARK: - END
}
