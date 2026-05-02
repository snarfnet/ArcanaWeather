import Foundation

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var selectedCity = City.all[0]
    @Published var condition = "薄曇り"
    @Published var temperature = "22°"
    @Published var details = "湿度 64% / 風 4m/s / 気圧 1011hPa"
    @Published var source = "天気データを読み込み中"
    @Published var moon = "上弦の月"
    @Published var planet = "金星の時"
    @Published var card = ArcanaDeck.cards[2]
    @Published var isLoading = false
    @Published var forecast: [ForecastDay] = [
        ForecastDay(day: "月", condition: "雨のち曇り", temperature: "18°", omen: "水 / 月"),
        ForecastDay(day: "火", condition: "薄曇り", temperature: "22°", omen: "風 / 水星"),
        ForecastDay(day: "水", condition: "快晴", temperature: "27°", omen: "火 / 太陽")
    ]

    var interpretation: String {
        ArcanaDeck.interpretation(for: card, condition: condition)
    }

    func select(_ city: City) async {
        selectedCity = city
        await loadWeather()
    }

    func selectGPS(lat: Double, lon: Double) async {
        let city = City.gps(lat: lat, lon: lon)
        selectedCity = city
        await loadWeather()
    }

    func loadWeather() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await WeatherService.fetch(city: selectedCity)
            apply(response)
            source = "Open-Meteo / \(selectedCity.name)"
        } catch {
            useDemoWeather()
            source = "デモデータ / \(selectedCity.name)"
        }
    }

    func useDemoWeather() {
        let demos: [(String, String, String, String, String, ArcanaCard)] = [
            ("薄曇り", "22°", "湿度 64% / 風 4m/s / 気圧 1011hPa", "上弦の月", "金星の時", ArcanaDeck.cards[2]),
            ("雨", "18°", "湿度 88% / 風 2m/s / 気圧 1002hPa", "下弦の月", "月の時", ArcanaDeck.cards[18]),
            ("快晴", "27°", "湿度 48% / 風 5m/s / 気圧 1018hPa", "太陽の潮流", "太陽の時", ArcanaDeck.cards[19])
        ]
        let demo = demos.randomElement()!
        condition = demo.0
        temperature = demo.1
        details = demo.2
        moon = demo.3
        planet = demo.4
        card = demo.5
    }

    private func apply(_ response: OpenMeteoResponse) {
        let current = response.current
        condition = WeatherCodes.label(for: current.weatherCode)
        temperature = "\(Int(current.temperature2m.rounded()))°"
        details = "湿度 \(Int(current.relativeHumidity2m.rounded()))% / 風 \(Int(current.windSpeed10m.rounded()))m/s / 気圧 \(Int(current.surfacePressure.rounded()))hPa"

        let tone = WeatherCodes.tone(for: current.weatherCode)
        moon = tone.moon
        planet = tone.planet
        card = ArcanaDeck.pick(current: current)

        forecast = response.daily.time.prefix(5).enumerated().map { index, date in
            let code = response.daily.weatherCode[index]
            let temp = Int(response.daily.temperature2mMax[index].rounded())
            let weatherKey = WeatherCodes.key(for: code)
            let elementMap = ["clear": "火", "rain": "水", "storm": "火", "fog": "地", "snow": "水", "cloudy": "風"]
            let element = elementMap[weatherKey] ?? "風"
            return ForecastDay(
                day: WeatherCodes.weekday(from: date),
                condition: WeatherCodes.label(for: code),
                temperature: "\(temp)°",
                omen: "\(element) / \(WeatherCodes.label(for: code))"
            )
        }
    }
}
