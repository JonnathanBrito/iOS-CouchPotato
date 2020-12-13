//
//  ViewController.swift
//  CouchPotato
//
//  Created by Jonnathan Brito on 11/16/20.
//


//Using TMDB API

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var loginButton: UIButton!
    

    
    
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
        Utilities.styleFilledButton(loginButton)
    }
}
