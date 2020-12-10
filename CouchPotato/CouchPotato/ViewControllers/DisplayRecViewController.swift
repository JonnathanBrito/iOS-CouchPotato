//
//  DisplayRecViewController.swift
//  CouchPotato
//
//  Created by Jonnathan Brito on 11/25/20.
//

import UIKit

class DisplayRecViewController: UIViewController {

    @IBOutlet weak var TopLeftButton: UIButton!
    
    @IBOutlet weak var TopRightButton: UIButton!
    
    @IBOutlet weak var BottomLeftButton: UIButton!
    
    @IBOutlet weak var BottomRightButton: UIButton!
    
    @IBOutlet weak var HomeButton: UIButton!
    
    @IBOutlet weak var LibraryButton: UIButton!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        // Do any additional setup after loading the view.
    }
    

    
//    @IBAction func LibraryButtonTapped(_ sender: Any) {
//        let showTable = MoviesTableViewController()
//        navigationController?.pushViewController(showTable, animated: true)
//    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
