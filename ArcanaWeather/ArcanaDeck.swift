import Foundation

enum ArcanaDeck {
    static let cards: [ArcanaCard] = [
        ArcanaCard(id: 0, name: "The Fool", nameJP: "愚者", glyph: "0", rune: "Fehu", symbol: "F", sephira: "Kether", element: "風", practice: "新しい道を一歩だけ試す"),
        ArcanaCard(id: 1, name: "The Magician", nameJP: "魔術師", glyph: "\u{221E}", rune: "Ansuz", symbol: "A", sephira: "Hod", element: "風", practice: "言葉を一つ整える"),
        ArcanaCard(id: 2, name: "The High Priestess", nameJP: "女教皇", glyph: "II", rune: "Perthro", symbol: "P", sephira: "Yesod", element: "水", practice: "沈黙を3分置く"),
        ArcanaCard(id: 3, name: "The Empress", nameJP: "女帝", glyph: "\u{2640}", rune: "Berkano", symbol: "B", sephira: "Netzach", element: "地", practice: "身体が喜ぶものを選ぶ"),
        ArcanaCard(id: 4, name: "The Emperor", nameJP: "皇帝", glyph: "\u{2648}", rune: "Tiwaz", symbol: "T", sephira: "Geburah", element: "火", practice: "境界線を一つ引く"),
        ArcanaCard(id: 5, name: "The Hierophant", nameJP: "教皇", glyph: "V", rune: "Othala", symbol: "O", sephira: "Chesed", element: "地", practice: "古い知恵を一つ読む"),
        ArcanaCard(id: 6, name: "The Lovers", nameJP: "恋人", glyph: "\u{2661}", rune: "Gebo", symbol: "G", sephira: "Tiphereth", element: "風", practice: "選択の理由を書く"),
        ArcanaCard(id: 7, name: "The Chariot", nameJP: "戦車", glyph: "\u{263D}", rune: "Raidho", symbol: "R", sephira: "Binah", element: "水", practice: "移動の前に深呼吸"),
        ArcanaCard(id: 8, name: "Strength", nameJP: "力", glyph: "\u{264C}", rune: "Uruz", symbol: "U", sephira: "Geburah", element: "火", practice: "力をやさしく使う"),
        ArcanaCard(id: 9, name: "The Hermit", nameJP: "隠者", glyph: "\u{2736}", rune: "Isa", symbol: "I", sephira: "Malkuth", element: "地", practice: "予定を一つ減らす"),
        ArcanaCard(id: 10, name: "Wheel of Fortune", nameJP: "運命の輪", glyph: "\u{2295}", rune: "Jera", symbol: "J", sephira: "Chesed", element: "風", practice: "流れの変化を記録"),
        ArcanaCard(id: 11, name: "Justice", nameJP: "正義", glyph: "\u{2696}", rune: "Tiwaz", symbol: "T", sephira: "Geburah", element: "風", practice: "事実と解釈を分ける"),
        ArcanaCard(id: 12, name: "The Hanged Man", nameJP: "吊るされた男", glyph: "\u{2646}", rune: "Eihwaz", symbol: "E", sephira: "Hod", element: "水", practice: "逆の見方を試す"),
        ArcanaCard(id: 13, name: "Death", nameJP: "死神", glyph: "\u{264F}", rune: "Hagalaz", symbol: "H", sephira: "Netzach", element: "水", practice: "終わらせるものを選ぶ"),
        ArcanaCard(id: 14, name: "Temperance", nameJP: "節制", glyph: "\u{2651}", rune: "Laguz", symbol: "L", sephira: "Tiphereth", element: "水", practice: "混ぜすぎず整える"),
        ArcanaCard(id: 15, name: "The Devil", nameJP: "悪魔", glyph: "\u{2651}", rune: "Nauthiz", symbol: "N", sephira: "Hod", element: "地", practice: "執着を一つ見つける"),
        ArcanaCard(id: 16, name: "The Tower", nameJP: "塔", glyph: "\u{265C}", rune: "Thurisaz", symbol: "Th", sephira: "Geburah", element: "火", practice: "大きな判断を寝かせる"),
        ArcanaCard(id: 17, name: "The Star", nameJP: "星", glyph: "\u{2726}", rune: "Wunjo", symbol: "W", sephira: "Netzach", element: "風", practice: "回復の兆しを書く"),
        ArcanaCard(id: 18, name: "The Moon", nameJP: "月", glyph: "\u{263E}", rune: "Laguz", symbol: "L", sephira: "Binah", element: "水", practice: "夢の断片を書く"),
        ArcanaCard(id: 19, name: "The Sun", nameJP: "太陽", glyph: "\u{2609}", rune: "Sowilo", symbol: "S", sephira: "Tiphereth", element: "火", practice: "今日の一語を決める"),
        ArcanaCard(id: 20, name: "Judgement", nameJP: "審判", glyph: "\u{2727}", rune: "Dagaz", symbol: "D", sephira: "Kether", element: "火", practice: "呼び戻すものを選ぶ"),
        ArcanaCard(id: 21, name: "The World", nameJP: "世界", glyph: "\u{25CE}", rune: "Ingwaz", symbol: "Ng", sephira: "Malkuth", element: "地", practice: "完了したことを祝う")
    ]

    static func pick(current: CurrentWeather) -> ArcanaCard {
        let hour = Calendar.current.component(.hour, from: ISO8601DateFormatter().date(from: current.time) ?? Date())
        let seed = abs(
            Int((current.temperature2m * 10).rounded()) +
            Int(current.relativeHumidity2m.rounded()) +
            Int((current.windSpeed10m * 3).rounded()) +
            Int(current.surfacePressure.rounded()) +
            current.weatherCode * 7 +
            hour
        )
        return cards[seed % cards.count]
    }

    static func interpretation(for card: ArcanaCard, condition: String) -> String {
        let tone: String
        switch card.element {
        case "風": tone = "思考、言葉、風向き"
        case "水": tone = "夢、感情、記憶"
        case "火": tone = "意志、行動、熱"
        default: tone = "身体、境界、現実"
        }
        return "\(condition)の空の下、今日は「\(card.nameJP)」の相。\(tone)を手がかりに、天気を予報だけでなく内省の地図として読む。"
    }
}
