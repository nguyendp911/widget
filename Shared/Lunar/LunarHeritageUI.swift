import SwiftUI
import UIKit

/// Native buttons use the user's original Vietnamese heritage artwork.
enum LunarHeritageUI {
    static func art(_ title: String) -> String? {
        let mapping: [(String, String, String)] = [
            ("Nguyên Đán","HeritageFestivalTet","HeritagePeach"),
            ("Táo","HeritageFestivalTao","HeritageGate"),
            ("Hùng Vương","HeritageFestivalHungKings","HeritageGate"),
            ("Hàn Thực","HeritageFestivalHanThuc","HeritageCloud"),
            ("Đoan Ngọ","HeritageFestivalDuanNgo","HeritageBamboo"),
            ("Vu Lan","HeritageFestivalVuLan","HeritageLotus"),
            ("Trung Thu","HeritageFestivalMidAutumn","HeritageLantern"),
            ("Trùng Cửu","HeritageFestivalTrungCuu","HeritagePeach"),
            ("Hạ Nguyên","HeritageFestivalHaNguyen","HeritageLotus")
        ]
        for (match, desired, fallback) in mapping where title.contains(match) {
            return UIImage(named: desired) == nil ? fallback : desired
        }
        return nil
    }
}

struct LunarHeritageIconButton: View {
    let image: String
    let fallback: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if UIImage(named: image) != nil {
                    Image(image).resizable().scaledToFit().frame(width: 37, height: 37)
                } else {
                    Image(systemName: fallback)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color(hex: "#9E2922"))
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "#F8EACB"), in: Circle())
                        .overlay(Circle().stroke(Color(hex: "#D9A545"), lineWidth: 1.4))
                }
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
