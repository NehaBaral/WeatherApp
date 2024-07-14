import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet var searchIcon: UIImageView!
    @IBOutlet var weatherImage: UIImageView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var locationItem: UIBarButtonItem!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet var switchButton: UISegmentedControl!
    
    @IBAction func cityButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "weatherListScreen", sender: self)
        
    }
    var weatherData = WeatherDataService()
    private let locationManager = CLLocationManager()
    var searchedCitiesWeather: [weatherDataObject] = []
    var isCelsius: Bool = true
    var currentWeatherInfo: weatherDataObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        weatherData.delegate = self
    
        self.navigationItem.titleView = searchBar
        self.navigationItem.leftBarButtonItem = locationItem

      
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        
        
        searchBar.searchTextField.textAlignment = .right
        searchBar.searchTextField.placeholder = "Search Location"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchIcon)
        
        locationManager.delegate = self
        
        // Set up segmented control action
        switchButton.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        // Add tap gesture recognizer to the search icon
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchIconTapped))
        searchIcon.isUserInteractionEnabled = true
        searchIcon.addGestureRecognizer(tapGestureRecognizer)
        
        // Request initial location to display weather info
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    @IBAction func locationButton(_ sender: UIBarButtonItem) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func displayLocation(locationText: String) {
        weatherDetails(location: locationText)
    }

    @objc func weatherDetails(location: String) {
        weatherData.getWeatherApi(coordinates: location)
    }

    func addCityWeather(_ weather: weatherDataObject) {
        if let existingIndex = searchedCitiesWeather.firstIndex(where: { $0.location.lat == weather.location.lat && $0.location.lon == weather.location.lon }) {
             
              searchedCitiesWeather[existingIndex] = weather
          } else {
           
              searchedCitiesWeather.append(weather)
          }
    }
 

    // Prepare for segue to pass data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "weatherListScreen" {
            if let citiesVC = segue.destination as? SecondScreenViewController {
                citiesVC.citiesWeather = searchedCitiesWeather
                citiesVC.isCelsius = isCelsius
            }
        }
    }



    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        isCelsius = sender.selectedSegmentIndex == 0
        updateTemperatureLabel()
    }
    
    private func updateTemperatureLabel() {
        if let info = currentWeatherInfo {
            temperature.text = isCelsius ? String(info.current.temp_c) : String(info.current.temp_f)
        }
    }
    
    @objc func searchIconTapped() {
        if let searchText = searchBar.text, !searchText.isEmpty {
            weatherDetails(location: searchText)
        }
        searchBar.resignFirstResponder()
    }
}

extension ViewController: WeatherManagerDelegate {
    func didFailWithError(error: Error) {
        print("Error: \(error)")
    }
    
    func didUpdateWeatherInformation(info: weatherDataObject) {
        DispatchQueue.main.async {
            self.currentWeatherInfo = info
            self.weatherCondition.text = info.current.condition.text
            self.city.text = info.location.name
            self.addCityWeather(info)
            self.updateTemperatureLabel()
          
            var iconURLString = info.current.condition.icon
            if !iconURLString.hasPrefix("http://") && !iconURLString.hasPrefix("https://") {
                iconURLString = "https:" + iconURLString
            }
            
            if let iconURL = URL(string: iconURLString) {
                self.loadImage(from: iconURL)
            }
        }
    }
    
    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    self.weatherImage.image = UIImage(data: data)
                }
            } else {
                print("Error loading image: \(String(describing: error))")
            }
        }
        task.resume()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            displayLocation(locationText: "\(latitude),\(longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            weatherDetails(location: searchText)
        }
        searchBar.resignFirstResponder()
    }
}
