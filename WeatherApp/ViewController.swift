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
    var filteredCities: [City] = []
    var weatherService = WeatherServiceWorker()
    var searchedCitiesWeather: [weatherModel] = []
    var isCelsius: Bool = true
    var currentWeatherInfo: weatherModel?
    
    @IBAction func cityButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "weatherListScreen", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        weatherService.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        locationManager.delegate = self
        filteredCities = cityList
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
        filteredCities.removeAll()
        self.tableView.reloadData()
        self.searchBar.text = ""
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
        weatherService.getWeatherFromCoordinates(coordinates: location)
    }
    
    func addCityWeather(_ weather: weatherModel) {
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
    
    func didUpdateWeatherInformation(info: weatherModel) {
        DispatchQueue.main.async {
            self.loading.stopAnimating()
            self.currentWeatherInfo = info
            self.weatherCondition.text = info.current.condition.text
            self.city.text = info.location.name 
            //+ ", " + info.location.country
            self.addCityWeather(info)
            self.updateTemperatureLabel()
                     
            let (symbol, color1, color2) = getWeatherSymbolAndColor(forCode: info.current.condition.code,
                                                        isDay: info.current.is_day)
                               
                               if let symbol = symbol, let color1 = color1, let color2 = color2 {
                                   let config = UIImage.SymbolConfiguration(paletteColors: [color1,color2])
                                   self.weatherImage.preferredSymbolConfiguration = config
                                   let iconImage = UIImage(systemName: symbol)
                                   self.weatherImage.image = iconImage!
                                   
                               } else {
                                   print("Weather symbol or color not found for code ")
                               }
            
           
        }
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
            weatherService.getWeatherFromCoordinates(coordinates: searchBar.text ?? "")
            filteredCities.removeAll()
            self.tableView.reloadData()
            self.searchBar.text = ""
            tableView.isHidden = true
            self.navigationItem.rightBarButtonItem = searchBarButton
        }
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.isHidden = false
        self.navigationItem.rightBarButtonItem = cancelButton
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.isHidden = false
        
        if(cityList.count != 0) {
            filteredCities = cityList
        }
        
        if !searchText.isEmpty {
            weatherService.getWeatherFromLocationSearch(city: searchText)
        } else {
          
            filteredCities.removeAll()
                self.tableView.reloadData()
        }
        self.tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchcell", for: indexPath) as UITableViewCell
        let cityName = filteredCities[indexPath.row]
        
        if cityName.region != "" {
            cell.textLabel?.text = "\(cityName.name), \(cityName.region), \(cityName.country)"
        }
        else {
            cell.textLabel?.text = "\(cityName.name), \(cityName.country)"
        }
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let latloncoordinates = "\(filteredCities[indexPath.row].lat), \(filteredCities[indexPath.row].lon)"
        weatherDetails(location: latloncoordinates)
        
        filteredCities.removeAll()
            self.tableView.reloadData()
            self.tableView.isHidden = true
            self.searchBar.text = ""
            self.searchBar.resignFirstResponder()
            self.navigationItem.rightBarButtonItem = searchBarButton
        }
        
    }
