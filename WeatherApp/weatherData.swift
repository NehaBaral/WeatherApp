import Foundation

protocol WeatherManagerDelegate {
    func startLoading()
    func didUpdateWeatherInformation(info: weatherModel)
    func didRecieveCities(info: [City])
    func didFailWithError(error: Error)
}

let APIKey = "abbac59e4cf84b918c3142625241207"
let baseURL = "http://api.weatherapi.com/v1"

struct WeatherServiceWorker {

    var delegate : WeatherManagerDelegate?
    let currentLocationURL = "\(baseURL)/current.json?key=\(APIKey)&q="
    let searchLocationURL = "\(baseURL)/search.json?key=\(APIKey)&q="
    
    func getWeatherFromCoordinates(coordinates: String) {
       getWeatherFromAPI(urlValue: currentLocationURL, data: coordinates, currentLocation: true)
    }

    func getWeatherFromLocationSearch(city: String) {
        getWeatherFromAPI(urlValue: searchLocationURL, data: city, currentLocation: false)
    }
    
    func getWeatherFromAPI(urlValue: String, data:String, currentLocation:Bool) {
        guard let url = URL(string: "\(urlValue)\(data)") else {
            let error = NSError(domain: "Invalid URL", code: 400, userInfo: nil)
            delegate?.didFailWithError(error: error)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.didFailWithError(error: error)
                }
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "No data received", code: 500, userInfo: nil)
                DispatchQueue.main.async {
                    self.delegate?.didFailWithError(error: error)
                }
                return
            }

            let decoder = JSONDecoder()
            do {
                if(currentLocation) {
                    let response = try decoder.decode(weatherModel.self, from: data)
                    DispatchQueue.main.async {
                        self.delegate?.didUpdateWeatherInformation(info: response)
                    }
                   
                } else {
                    let response:[City] = try decoder.decode([City].self, from: data)
                    
                    DispatchQueue.main.async {
                        self.delegate?.didRecieveCities(info: response)
                    }
                }
            } catch {
             
                DispatchQueue.main.async {
                    self.delegate?.didFailWithError(error: error)
                }
            }
        }
        task.resume()
    }
}
