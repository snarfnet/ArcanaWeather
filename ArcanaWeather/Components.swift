import SwiftUI

struct SigilView: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
            Rectangle()
                .stroke(Color.teal.opacity(0.65), lineWidth: 1)
                .frame(width: 112, height: 112)
                .rotationEffect(.degrees(45))
            Circle()
                .stroke(Color(red: 0.61, green: 0.19, blue: 0.28).opacity(0.68), lineWidth: 1)
                .frame(width: 72, height: 72)
            Rectangle()
                .fill(Color.yellow.opacity(0.8))
                .frame(width: 2, height: 142)
            Rectangle()
                .fill(Color.yellow.opacity(0.8))
                .frame(width: 142, height: 2)
            Circle()
                .fill(Color.white)
                .frame(width: 13, height: 13)
                .shadow(color: .yellow.opacity(0.85), radius: 12)
        }
    }
}

struct OmenPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(Color.black.opacity(0.16), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12)))
    }
}

struct SymbolTile: View {
    let title: String
    let value: String
    let glyph: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.045))
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.yellow.opacity(0.22))
                Ellipse()
                    .stroke(Color.teal.opacity(0.35))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                Text(glyph)
                    .font(.system(size: 52, weight: .semibold, design: .serif))
                    .foregroundStyle(.yellow)
                    .shadow(color: .yellow.opacity(0.35), radius: 12)
            }
            .frame(height: 92)

            Text(title.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
        .padding(14)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12)))
    }
}

struct InfoTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .topLeading)
        .padding(14)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12)))
    }
}
