import Foundation

struct City: Identifiable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double

    static let all: [City] = [
        City(id: "tokyo", name: "東京", latitude: 35.6895, longitude: 139.6917),
        City(id: "kyoto", name: "京都", latitude: 35.0116, longitude: 135.7681),
        City(id: "osaka", name: "大阪", latitude: 34.6937, longitude: 135.5023),
        City(id: "sapporo", name: "札幌", latitude: 43.0618, longitude: 141.3545),
        City(id: "naha", name: "那覇", latitude: 26.2124, longitude: 127.6792)
    ]

    static func gps(lat: Double, lon: Double) -> City {
        City(id: "gps", name: "現在地", latitude: lat, longitude: lon)
    }
}

struct ArcanaCard: Identifiable {
    let id: Int
    let name: String
    let nameJP: String
    let glyph: String
    let rune: String
    let symbol: String
    let sephira: String
    let element: String
    let practice: String

    var imageName: String {
        "tarot-" + name.lowercased().replacingOccurrences(of: " ", with: "-")
    }
}

struct ForecastDay: Identifiable {
    let id = UUID()
    let day: String
    let condition: String
    let temperature: String
    let omen: String
}

struct OpenMeteoResponse: Decodable {
    let current: CurrentWeather
    let daily: DailyWeather
}

struct CurrentWeather: Decodable {
    let time: String
    let temperature2m: Double
    let relativeHumidity2m: Double
    let weatherCode: Int
    let surfacePressure: Double
    let windSpeed10m: Double

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case weatherCode = "weather_code"
        case surfacePressure = "surface_pressure"
        case windSpeed10m = "wind_speed_10m"
    }
}

struct DailyWeather: Decodable {
    let time: [String]
    let weatherCode: [Int]
    let temperature2mMax: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMax = "temperature_2m_max"
    }
}
