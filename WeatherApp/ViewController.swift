import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet var weatherImage: UIImageView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var locationItem: UIBarButtonItem!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet var switchButton: UISegmentedControl!
    @IBOutlet weak var loading: UIActivityIndicatorView!

    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var searchBarButton: UIBarButtonItem!
    

    @IBOutlet weak var tableView: UITableView!
    
    private let locationManager = CLLocationManager()
    var cityList: [City] = []
    var weatherData = WeatherDataService()
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        locationManager.delegate = self
        
        // Navigation Item
        self.navigationItem.titleView = searchBar
        self.navigationItem.leftBarButtonItem = locationItem
        self.navigationItem.rightBarButtonItem = searchBarButton
        
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        
       // searchBar.searchTextField.textAlignment = .right
        searchBar.searchTextField.placeholder = "Search Location"
        
        
        // Set up segmented control action
        switchButton.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        // selected option color
        switchButton.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)

        // color of other options
        switchButton.setTitleTextAttributes([.foregroundColor: UIColor.blue], for: .normal)
        
        // Request initial location to display weather info
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        tableView.isHidden = true
        searchBar.resignFirstResponder()
        self.navigationItem.rightBarButtonItem = searchBarButton
    }
    
    @IBAction func searchButton(_ sender: UIBarButtonItem) {
        tableView.isHidden = false
        searchBar.becomeFirstResponder()
        self.navigationItem.rightBarButtonItem = cancelButton

    }
    
    //Updating out own location in weatherapp
    @IBAction func locationButton(_ sender: UIBarButtonItem) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
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
    
    func didRecieveCities(info: [City]) {
        cityList = info
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
            weatherDetails(location: "\(latitude),\(longitude)")
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.isHidden = false
        self.navigationItem.rightBarButtonItem = cancelButton
        }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.isHidden = false
        weatherData.getWeatherFromCity(city: searchText)
        
        if searchText.isEmpty {
            print("Clear button (X button) was tapped in the search bar.")
            self.tableView.isHidden = true
        }
        self.tableView.reloadData()
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchcell", for: indexPath)
        
        if indexPath.row < cityList.count {
            let cityName = cityList[indexPath.row]
            cell.textLabel?.text = "\(cityName.name), \(cityName.region), \(cityName.country)"
        } else {
            print("Index out of bounds: \(indexPath.row)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row < cityList.count {
            weatherData.getWeatherApi(coordinates: " \(cityList[indexPath.row].lat), \(cityList[indexPath.row].lon)")
        }
        
        cityList.removeAll()
        self.tableView.reloadData()
        self.tableView.isHidden = true
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.navigationItem.rightBarButtonItem = searchBarButton

    }
}
