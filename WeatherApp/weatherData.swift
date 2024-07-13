//
//  weatherData.swift
//  WeatherApp
//
//  Created by Sangeetha Thyagarajan on 2024-07-12.
//

import Foundation
import UIKit


protocol weatherManagerDelegate {
    func didUpdaterWeatherInformation(info: weatherDataObject)
    func didFailWithError(info: Error)
}
var APIKey = "abbac59e4cf84b918c3142625241207"

struct WeatherDataService {
    var delegate: weatherManagerDelegate?
    var baseURL = "http://api.weatherapi.com/v1/current.json?key=\(APIKey)&q="
    
    func getWeatherApi(coordinates: String) {
        guard let url = URL(string: "\(baseURL)\(coordinates)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = nil
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
                let decoder = JSONDecoder()
               do {
                   let response: weatherDataObject = try decoder.decode(weatherDataObject.self, from: data)
                    self.delegate?.didUpdaterWeatherInformation(info: response)
                }
             
            catch {
                print(error)
                self.delegate?.didFailWithError(info: error)
            }
        }
        task.resume()
    }
   
}

