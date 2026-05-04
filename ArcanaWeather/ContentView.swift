import SwiftUI

private let kTopBannerID    = "ca-app-pub-9404799280370656/6184843001"
private let kBottomBannerID = "ca-app-pub-9404799280370656/7134962596"

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var journal = JournalManager()
    @State private var selectedTab: ArcanaTab = .oracle
    @State private var journalText = ""
    @State private var journalSaved = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.04, blue: 0.06), Color(red: 0.11, green: 0.06, blue: 0.09), Color(red: 0.04, green: 0.10, blue: 0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                BannerAdView(adUnitID: kTopBannerID).frame(height: 50)

                ScrollView {
                    VStack(spacing: 18) {
                        header
                        cityPicker
                        skyPanel
                        tabPicker

                        switch selectedTab {
                        case .oracle:
                            oracleView
                        case .forecast:
                            forecastView
                        case .journal:
                            journalView
                        }

                        Text("天気は気象データ、象徴解釈は内省・娯楽・文化研究のための表示です。")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 6)
                    }
                    .padding(18)
                }

                BannerAdView(adUnitID: kBottomBannerID).frame(height: 50)
            }
        }
        .preferredColorScheme(.dark)
        .task {
            await viewModel.loadWeather()
            journalText = journal.getText(for: journal.todayKey)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("ARCANA WEATHER")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.selectedCity.name)
                    .font(.system(size: 38, weight: .medium, design: .serif))
            }
            Spacer()

            if viewModel.isLoading {
                ProgressView()
                    .frame(width: 46, height: 46)
            } else {
                Button {
                    Task {
                        if let loc = await locationManager.requestLocation() {
                            await viewModel.selectGPS(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
                        }
                    }
                } label: {
                    Image(systemName: "location.fill")
                        .font(.body)
                        .foregroundStyle(.teal)
                        .frame(width: 46, height: 46)
                        .background(.white.opacity(0.06), in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.12)))
                }
                .accessibilityLabel("現在地の天気")
            }
        }
    }

    // MARK: - City Picker

    private var cityPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(City.all) { city in
                    Button(city.name) {
                        Task { await viewModel.select(city) }
                    }
                    .font(.caption)
                    .foregroundStyle(viewModel.selectedCity.id == city.id ? .white : .secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(viewModel.selectedCity.id == city.id ? Color.teal.opacity(0.22) : Color.white.opacity(0.07), in: Capsule())
                    .overlay(Capsule().stroke(viewModel.selectedCity.id == city.id ? Color.teal.opacity(0.65) : Color.white.opacity(0.12)))
                }
            }
        }
    }

    // MARK: - Sky Panel

    private var skyPanel: some View {
        VStack(spacing: 14) {
            Image(viewModel.card.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 240)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .yellow.opacity(0.3), radius: 12)

            VStack(spacing: 3) {
                Text(viewModel.condition)
                    .foregroundStyle(.teal)
                Text(viewModel.temperature)
                    .font(.system(size: 72, weight: .ultraLight))
                Text(viewModel.interpretation)
                    .font(.caption)
                    .foregroundStyle(.primary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                Text(viewModel.details)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.source)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack {
                OmenPill(text: viewModel.moon)
                OmenPill(text: viewModel.planet)
                OmenPill(text: viewModel.card.element)
            }
        }
        .padding(22)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.yellow.opacity(0.18)))
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack(spacing: 6) {
            ForEach(ArcanaTab.allCases) { tab in
                Button(tab.title) {
                    selectedTab = tab
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .foregroundStyle(selectedTab == tab ? .yellow : .white)
                .background(selectedTab == tab ? Color.yellow.opacity(0.14) : Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(selectedTab == tab ? Color.yellow.opacity(0.55) : Color.white.opacity(0.12)))
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Oracle

    private var oracleView: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                Text("今日の象徴")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.card.nameJP)  \(viewModel.card.name)")
                    .font(.system(size: 24, weight: .medium, design: .serif))
                Text(viewModel.interpretation)
                    .font(.body)
                    .foregroundStyle(.primary.opacity(0.86))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12)))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                SymbolTile(title: "タロット", value: viewModel.card.nameJP, glyph: viewModel.card.glyph)
                SymbolTile(title: "ルーン", value: viewModel.card.rune, glyph: viewModel.card.symbol)
                InfoTile(title: "セフィラ", value: viewModel.card.sephira)
                InfoTile(title: "実践", value: viewModel.card.practice)
            }
        }
    }

    // MARK: - Forecast

    private var forecastView: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.forecast) { day in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.day)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(day.condition)
                        Text(day.omen)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(day.temperature)
                        .font(.system(size: 32, weight: .light))
                }
                .padding(14)
                .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12)))
            }
        }
    }

    // MARK: - Journal

    private var journalView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Today's entry
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("今日の記録")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(journal.dateLabel(for: journal.todayKey))
                        .font(.caption)
                        .foregroundStyle(.teal)
                }

                TextEditor(text: $journalText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12)))

                Button {
                    journal.save(text: journalText, card: viewModel.card.nameJP, condition: viewModel.condition)
                    journalSaved = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { journalSaved = false }
                } label: {
                    Text(journalSaved ? "保存しました ✓" : "保存")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(journalSaved ? Color.green.opacity(0.28) : Color.teal.opacity(0.22), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(journalSaved ? Color.green.opacity(0.65) : Color.teal.opacity(0.65)))
                }
                .animation(.easeInOut(duration: 0.2), value: journalSaved)
            }

            // Past entries
            let past = journal.recentEntries.filter { $0.dateKey != journal.todayKey }
            if !past.isEmpty {
                Text("過去の記録")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)

                ForEach(past) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(journal.dateLabel(for: entry.dateKey))
                                .font(.caption)
                                .foregroundStyle(.teal)
                            Spacer()
                            Text("\(entry.card) / \(entry.condition)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text(entry.text)
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.86))
                            .lineLimit(3)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12)))
                }
            }
        }
    }
}

enum ArcanaTab: String, CaseIterable, Identifiable {
    case oracle
    case forecast
    case journal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .oracle: return "神託"
        case .forecast: return "予報"
        case .journal: return "日記"
        }
    }
}

#Preview {
    ContentView()
}
