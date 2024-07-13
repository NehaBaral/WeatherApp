//
//  ViewController.swift
//  WeatherApp
//
//  Created by Neha on 2024-07-10.
//

import UIKit
import CoreLocation
import SwiftUI
class ViewController: UIViewController {
    
    @IBOutlet var searchIcon: UIImageView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var locationItem: UIBarButtonItem!
    
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var weatherCondition: UILabel!
    var weatherData = WeatherDataService()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        weatherData.delegate = self
    
        self.navigationItem.titleView = searchBar
        
        //Remove the searchIcon from the left position of search bar
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        
        //Alignment of text from right to left
        searchBar.searchTextField.textAlignment = .right
        searchBar.searchTextField.placeholder = "Search Location"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchIcon)
        
        
        locationManager.delegate = self
        
        self.navigationItem.leftBarButtonItem = locationItem

    }
    
    @IBAction func locationButton(_ sender: UIBarButtonItem) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func displayLocation(locationText: String) {
        weatherDetails(location: locationText)
    }

    @objc func weatherDetails(location: String) {
       
        weatherData.getWeatherApi(coordinates:location)
        
    }

}

extension ViewController : weatherManagerDelegate {
    func didFailWithError(info: any Error) {
        print(info)

    }
    
    func didUpdaterWeatherInformation(info: weatherDataObject) {
        DispatchQueue.main.async {
            print(info)
            self.weatherCondition.text = info.current.condition.text
            self.city.text = info.location.name
        }
    }
}


extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            displayLocation(locationText: "\(latitude),\(longitude)")

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
}

extension ViewController : UISearchBarDelegate{
    
}

