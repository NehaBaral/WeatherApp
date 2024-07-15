//
//  CityModel.swift
//  WeatherApp
//
//  Created by Sangeetha Thyagarajan on 2024-07-14.
//

import Foundation


struct City: Decodable {
    var country: String
    var id: Int
    var lat: Double
    var lon: Double
    var name: String
    var region: String
    var url: String
}

struct CityModel: Decodable {
    var data: [City]
}
