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
    @IBOutlet weak var loading: UIActivityIndicatorView!

    var weatherData = WeatherDataService()
    private let locationManager = CLLocationManager()
    var searchedCitiesWeather: [weatherDataObject] = []
    var isCelsius: Bool = true
    var currentWeatherInfo: weatherDataObject?
    
    @IBAction func cityButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "weatherListScreen", sender: self)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        weatherData.delegate = self
    
        // Navigation Item
        self.navigationItem.titleView = searchBar
        self.navigationItem.leftBarButtonItem = locationItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchIcon)
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        
       // searchBar.searchTextField.textAlignment = .right
        searchBar.searchTextField.placeholder = "Search Location"
        
        locationManager.delegate = self
        
        // Set up segmented control action
        switchButton.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        // selected option color
        switchButton.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)

        // color of other options
        switchButton.setTitleTextAttributes([.foregroundColor: UIColor.blue], for: .normal)
        
        // Add tap gesture recognizer to the search icon
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchIconTapped))
        searchIcon.isUserInteractionEnabled = true
        searchIcon.addGestureRecognizer(tapGestureRecognizer)
        
        // Request initial location to display weather info
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    //Updating out own location in weatherapp
    @IBAction func locationButton(_ sender: UIBarButtonItem) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func displayLocation(locationText: String) {
        weatherDetails(location: locationText)
    }

    func weatherDetails(location: String) {
        weatherData.getWeatherApi(coordinates: location)
    }

    func addCityWeather(_ weather: weatherDataObject) {
        if let existingIndex = searchedCitiesWeather.firstIndex(where: { $0.location.lat == weather.location.lat && $0.location.lon == weather.location.lon }) {
              searchedCitiesWeather[existingIndex] = weather
          } else {
           
              searchedCitiesWeather.append(weather)
          }
    }
    
    //start updating location
    func startUpdatingLocation(){
        locationManager.startUpdatingLocation()
        
    }
    
    //stop updating location
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
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
    
    //function to show alert
    private func showAlert(){
        let alert = UIAlertController(title: "Weather Fetching Error", message: "Try Again", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default){[self] _ in
          //  loginBtn.isEnabled = false
        }
        alert.addAction(okButton)
        present(alert,animated: true ,completion: nil)
    }
}

// Delegate to manage api call for the location
extension ViewController: WeatherManagerDelegate {
    func startLoading() {
        loading.startAnimating()
    }
    
    func didFailWithError(error: any Error) {
        loading.stopAnimating()
        showAlert()
    }
    
    
    
    func didUpdateWeatherInformation(info: weatherDataObject) {
        DispatchQueue.main.async {
            self.loading.stopAnimating()
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
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
            
        case .notDetermined:
            showAlert()
        case .restricted:
            showAlert()
        case .denied:
            showAlert()
        case .authorizedAlways:
            manager.requestAlwaysAuthorization()
            loading.startAnimating()
            startUpdatingLocation()
        case .authorizedWhenInUse:
            manager.requestWhenInUseAuthorization()
            loading.startAnimating()
            startUpdatingLocation()
        @unknown default:
            showAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            displayLocation(locationText: "\(latitude),\(longitude)")
        }else{
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        loading.stopAnimating()
        stopUpdatingLocation()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            weatherDetails(location: searchText)
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // have to work on search
        //i think we need to show recommendation when we add text on search bar
    }
}
