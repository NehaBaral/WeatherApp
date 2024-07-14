import Foundation

protocol WeatherManagerDelegate {
    func startLoading()
    func didUpdateWeatherInformation(info: weatherDataObject)
    func didFailWithError(error: Error)
    func didRecieveCities(info: [City])
}

let APIKey = "abbac59e4cf84b918c3142625241207"
let baseURL = "http://api.weatherapi.com/v1"

struct WeatherDataService {
    var delegate : WeatherManagerDelegate?
    
    let currentLocationURL = "\(baseURL)/current.json?key=\(APIKey)&q="
    let searchLocationURL = "\(baseURL)/search.json?key=\(APIKey)&q="
    
    func getWeatherApi(coordinates: String) {
        delegate?.startLoading()
        guard let url = URL(string: "\(currentLocationURL)\(coordinates)") else {
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
                let response = try decoder.decode(weatherDataObject.self, from: data)
                DispatchQueue.main.async {
                    self.delegate?.didUpdateWeatherInformation(info: response)
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailWithError(error: error)
                }
            }
        }
        task.resume()
    }
    
    
    func getWeatherFromCity(city: String) {
        guard let url = URL(string: "\(searchLocationURL)\(city)") else {
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
            print("incomisdng", data)

            let decoder = JSONDecoder()
            do {
                let response:[City] = try decoder.decode([City].self, from: data)
    
                DispatchQueue.main.async {
                    self.delegate?.didRecieveCities(info: response)
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
