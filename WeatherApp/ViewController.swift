//
//  ViewController.swift
//  WeatherApp
//
//  Created by Neha on 2024-07-10.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var locationIcon: UIImageView!
    
    @IBOutlet var searchIcon: UIImageView!
    @IBOutlet var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        let leftNavBarButton = UIBarButtonItem(customView:locationIcon)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        
        self.navigationItem.titleView = searchBar
        
        //Remove the searchIcon from the left position of search bar
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        
        //Alignment of text from right to left
        searchBar.searchTextField.textAlignment = .right
        searchBar.searchTextField.placeholder = "Search Location"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchIcon)
        
    }


}

extension ViewController : UISearchBarDelegate{
    
}

