import Foundation

protocol WeatherManagerDelegate: AnyObject {
    func didUpdateWeatherInformation(info: weatherDataObject)
    func didFailWithError(error: Error)
}

let APIKey = "abbac59e4cf84b918c3142625241207"

struct WeatherDataService {
    weak var delegate: (any WeatherManagerDelegate)?
    let baseURL = "http://api.weatherapi.com/v1/current.json?key=\(APIKey)&q="
    
    func getWeatherApi(coordinates: String) {
        guard let url = URL(string: "\(baseURL)\(coordinates)") else {
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
}
