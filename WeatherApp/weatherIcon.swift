import Foundation
import UIKit



let dayWeatherCodeToSymbol: [Int: String] = [
    1000: "sun.max.fill",
    1003: "cloud.sun.fill",
    1006: "cloud.fill",
    1009: "cloud.fog.fill",
    1030: "cloud.fog.fill",
    1063: "cloud.drizzle.fill",
    1066: "cloud.snow.fill",
    1069: "cloud.sleet.fill",
    1072: "cloud.hail.fill",
    1087: "cloud.bolt.fill",
    1114: "wind.snow",
    1117: "wind.snow",
    1135: "cloud.fog.fill",
    1147: "cloud.fog.fill",
    1150: "cloud.drizzle.fill",
    1153: "cloud.drizzle.fill",
    1168: "cloud.hail.fill",
    1171: "cloud.hail.fill",
    1180: "cloud.drizzle.fill",
    1183: "cloud.drizzle.fill",
    1186: "cloud.drizzle.fill",
    1189: "cloud.drizzle.fill",
    1192: "cloud.drizzle.fill",
    1195: "cloud.drizzle.fill",
    1198: "cloud.sleet.fill",
    1201: "cloud.sleet.fill",
    1204: "cloud.sleet.fill",
    1207: "cloud.sleet.fill",
    1210: "cloud.snow.fill",
    1213: "cloud.snow.fill",
    1216: "cloud.snow.fill",
    1219: "cloud.snow.fill",
    1222: "cloud.snow.fill",
    1225: "cloud.snow.fill",
    1237: "cloud.hail.fill",
    1240: "cloud.drizzle.fill",
    1243: "cloud.drizzle.fill",
    1246: "cloud.drizzle.fill",
    1249: "cloud.sleet.fill",
    1252: "cloud.sleet.fill",
    1255: "cloud.snow.fill",
    1258: "cloud.snow.fill",
    1261: "cloud.sleet.fill",
    1264: "cloud.sleet.fill",
    1273: "cloud.bolt.rain.fill",
    1276: "cloud.bolt.rain.fill",
    1279: "cloud.bolt.snow.fill",
    1282: "cloud.bolt.snow.fill"
]

let nightWeatherCodeToSymbol: [Int: String] = [
    1000: "moon.stars.fill",
    1003: "cloud.moon.fill",
    1006: "cloud.fill",
    1009: "cloud.fog.fill",
    1030: "cloud.fog.fill",
    1063: "cloud.drizzle.fill",
    1066: "cloud.snow.fill",
    1069: "cloud.sleet.fill",
    1072: "cloud.hail.fill",
    1087: "cloud.bolt.fill",
    1114: "wind.snow",
    1117: "wind.snow",
    1135: "cloud.fog.fill",
    1147: "cloud.fog.fill",
    1150: "cloud.drizzle.fill",
    1153: "cloud.drizzle.fill",
    1168: "cloud.hail.fill",
    1171: "cloud.hail.fill",
    1180: "cloud.drizzle.fill",
    1183: "cloud.drizzle.fill",
    1186: "cloud.drizzle.fill",
    1189: "cloud.drizzle.fill",
    1192: "cloud.drizzle.fill",
    1195: "cloud.drizzle.fill",
    1198: "cloud.sleet.fill",
    1201: "cloud.sleet.fill",
    1204: "cloud.sleet.fill",
    1207: "cloud.sleet.fill",
    1210: "cloud.snow.fill",
    1213: "cloud.snow.fill",
    1216: "cloud.snow.fill",
    1219: "cloud.snow.fill",
    1222: "cloud.snow.fill",
    1225: "cloud.snow.fill",
    1237: "cloud.hail.fill",
    1240: "cloud.drizzle.fill",
    1243: "cloud.drizzle.fill",
    1246: "cloud.drizzle.fill",
    1249: "cloud.sleet.fill",
    1252: "cloud.sleet.fill",
    1255: "cloud.snow.fill",
    1258: "cloud.snow.fill",
    1261: "cloud.sleet.fill",
    1264: "cloud.sleet.fill",
    1273: "cloud.bolt.rain.fill",
    1276: "cloud.bolt.rain.fill",
    1279: "cloud.bolt.snow.fill",
    1282: "cloud.bolt.snow.fill"
]




func getWeatherSymbolAndColor(forCode code: Int, isDay: Int) -> (symbol: String?, color1: UIColor?,color2:UIColor?) {
    let symbol = isDay == 1 ? dayWeatherCodeToSymbol[code] : nightWeatherCodeToSymbol[code]
    
    if isDay == 1 {
        switch code {
        case 1003:
            return(symbol,UIColor.white,UIColor.yellow)
        case 1000:
            return(symbol,UIColor.yellow,UIColor.white)
        case 1273, 1276, 1279, 1282:
            return (symbol, UIColor.darkGray, UIColor.purple)
        case 1150:
            return (symbol, UIColor.gray, UIColor.blue)
        default:
            let color = UIColor.gray.withAlphaComponent(0.6)
            return (symbol, color, UIColor.blue)
        }
    } else {
        return (symbol, UIColor.lightGray, UIColor.brown)
}



}

