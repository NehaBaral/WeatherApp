//
//  weatherModel.swift
//  WeatherApp
//
//  Created by Sangeetha Thyagarajan on 2024-07-12.
//

import Foundation

struct weatherDataObject: Decodable 
{
    let current: Current
    let location: Location
}

struct Current: Decodable {
    let cloud: Int
    let condition: Condition
//    let dewpointC: String
//    let dewpointF: String
//    let feelslikeC: String
//    let feelslikeF: String
//    let gustKph: String
//    let gustMph: String
//    let heatindexC: String
//    let heatindexF: String
//    let humidity: Int
//    let isDay: Int
//    let lastUpdated: String
//    let lastUpdatedEpoch: Double
//    let precipIn: Double
//    let precipMm: Double
//    let pressureIn: String
//    let pressureMb: Int
//    let tempC: Double
//    let tempF: Double
//    let uv: Int
//    let visKm: Int
//    let visMiles: Int
//    let windDegree: Int
//    let windDir: String
//    let windKph: Double
//    let windMph: Double
//    let windchillC: Double
//    let windchillF: Double
}

struct Condition : Decodable{
    let code: Int
    let icon: String
    let text: String
}

struct Location : Decodable{
    let country: String
    let lat: Double
    let localtime: String
//    let localtimeEpoch: Any
    let lon: Double
    let name: String
    let region: String
//    let tzId: String
}
