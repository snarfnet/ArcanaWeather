import Foundation

enum WeatherService {
    static func fetch(city: City) async throws -> OpenMeteoResponse {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(city.latitude)),
            URLQueryItem(name: "longitude", value: String(city.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,weather_code,surface_pressure,wind_speed_10m"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max"),
            URLQueryItem(name: "timezone", value: "Asia/Tokyo"),
            URLQueryItem(name: "forecast_days", value: "5"),
            URLQueryItem(name: "wind_speed_unit", value: "ms")
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
    }
}

enum WeatherCodes {
    static func label(for code: Int) -> String {
        switch code {
        case 0: return "快晴"
        case 1: return "晴れ"
        case 2: return "薄曇り"
        case 3: return "曇り"
        case 45, 48: return "霧"
        case 51, 53, 55, 61, 63, 65: return "雨"
        case 71, 73, 75: return "雪"
        case 80, 81, 82: return "にわか雨"
        case 95, 96, 99: return "雷雨"
        default: return "変わりやすい空"
        }
    }

    static func key(for code: Int) -> String {
        switch code {
        case 0, 1: return "clear"
        case 2, 3: return "cloudy"
        case 45, 48: return "fog"
        case 71, 73, 75: return "snow"
        case 95...99: return "storm"
        case 51...82: return "rain"
        default: return "cloudy"
        }
    }

    static func tone(for code: Int) -> (moon: String, planet: String) {
        switch key(for: code) {
        case "clear": return ("太陽の潮流", "太陽の時")
        case "rain": return ("下弦の月", "月の時")
        case "storm": return ("満月", "火星の時")
        case "fog": return ("闇月", "土星の時")
        case "snow": return ("銀月", "土星の時")
        default: return ("上弦の月", "金星の時")
        }
    }

    static func weekday(from dateText: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateText) else { return dateText }
        let display = DateFormatter()
        display.locale = Locale(identifier: "ja_JP")
        display.dateFormat = "E"
        return display.string(from: date)
    }
}
