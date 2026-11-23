import SwiftUI

/// The approved Vietnamese heritage kit is the front door to ViePN Widget+.
/// The fantasy Living Canvas catalogue is retained below as an optional studio.
struct DashboardView: View {
    @EnvironmentObject private var studio: WidgetStudioStore
    @EnvironmentObject private var tools: UtilityStore
    @EnvironmentObject private var lunarFamily: LunarFamilyStore

    private var today: SolarCivilDate {
        SolarCivilDate(date: .now) ?? SolarCivilDate(year: 2026, month: 11, day: 23)
    }

    private var events: [LunarEventOccurrence] {
        LunarEventScheduler.upcoming(events: lunarFamily.events, from: today, count: 3)
    }

    var body: some View {
        StudioPage {
            VStack(alignment: .leading, spacing: 19) {
                VStack(alignment: .leading, spacing: 8) {
                    ViePNHeritageRibbon(title: "VIEPN WIDGET+ · VIỆT NAM", color: "Red")
                        .frame(height: 53)
                    Text("Một ngày Việt. Một màn hình riêng.")
                        .font(.system(size: 29, weight: .semibold, design: .serif))
                        .foregroundStyle(Color(hex: "#FFF0D5"))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Lịch âm, ngày giỗ, Can Chi và những tiện ích bạn dùng mỗi ngày.")
                        .font(.system(size: 13))
                        .foregroundStyle(StudioPalette.muted)
                }
                .padding(.horizontal, 4)

                HStack {
                    Text("LỊCH ÂM HÔM NAY")
                        .font(.system(size: 11, weight: .semibold, design: .serif))
                        .tracking(0.8)
                        .foregroundStyle(StudioPalette.mint)
                    Spacer()
                    NavigationLink {
                        LunarCalendarHomeView()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Xem lịch vạn niên")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(StudioPalette.mint)
                    }
                }

                NavigationLink {
                    LunarCalendarHomeView()
                } label: {
                    LunarCardView(kind: .today, size: .medium, civil: today,
                                  appearance: lunarFamily.appearance, upcomingEvents: events)
                        .frame(height: 190)
                        .overlay(ViePNGoldWidgetBorder())
                }
                .buttonStyle(.plain)

                StudioPanel {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 9) {
                            Image("ViePNIconFamily")
                                .resizable().scaledToFit().frame(width: 30, height: 30)
                            Text("NHỮNG VIỆC KHÔNG QUÊN")
                                .font(.system(size: 11, weight: .semibold, design: .serif))
                                .foregroundStyle(StudioPalette.mint)
                            Spacer()
                        }
                        HStack(spacing: 12) {
                            metric("Ngân sách còn",
                                   value: tools.snapshot.revealOnWidgets
                                       ? tools.snapshot.remainingBudget().viepnVND : "••••••",
                                   glyph: "ViePNIconGoodDay")
                            metric("Việc cần làm",
                                   value: "\(tools.snapshot.pendingTasks.count) việc",
                                   glyph: "ViePNIconCalendar")
                        }
                        if let next = events.first {
                            HStack(spacing: 8) {
                                Image("ViePNIconMemorial")
                                    .resizable().scaledToFit().frame(width: 23, height: 23)
                                Text("\(next.title) · còn \(next.daysRemaining(from: today)) ngày")
                                    .font(.system(size: 12, weight: .medium, design: .serif))
                                    .foregroundStyle(Color(hex: "#FFF0D5"))
                                    .lineLimit(1)
                                Spacer(minLength: 2)
                            }
                        } else {
                            Text("Thêm ngày giỗ để luôn nhớ những dịp quan trọng.")
                                .font(.system(size: 11))
                                .foregroundStyle(StudioPalette.muted)
                        }
                    }
                }

                HStack {
                    Text("BỘ WIDGET ĐẬM CHẤT VIỆT")
                        .font(.system(size: 11, weight: .semibold, design: .serif))
                        .foregroundStyle(StudioPalette.mint)
                        .tracking(0.8)
                    Spacer()
                }

                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 12) {
                        heritagePreview(kind: .memorial, title: "Ngày giỗ", width: 286, height: 170)
                        heritagePreview(kind: .almanac, title: "Can Chi – Vạn Niên", width: 286, height: 170)
                        heritagePreview(kind: .moonDays, title: "Mùng 1 · Rằm", width: 170, height: 170)
                        heritagePreview(kind: .month, title: "Lịch tháng", width: 280, height: 286)
                    }
                }
                .scrollIndicators(.hidden)

                NavigationLink {
                    GalleryView()
                } label: {
                    HStack(spacing: 13) {
                        Image("ViePNIconCulture")
                            .resizable().scaledToFit().frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Khám phá bộ sưu tập")
                                .font(.system(size: 15, weight: .semibold, design: .serif))
                                .foregroundStyle(.white)
                            Text("Widget sáng tạo và giao diện cá nhân hóa")
                                .font(.system(size: 11)).foregroundStyle(StudioPalette.muted)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(StudioPalette.mint)
                    }
                    .padding(15)
                    .background(StudioPalette.surface, in: RoundedRectangle(cornerRadius: 19))
                    .overlay(RoundedRectangle(cornerRadius: 19)
                        .stroke(Color(hex: "#D7A34B").opacity(0.5), lineWidth: 1))
                }
                .buttonStyle(.plain)

                HStack {
                    Text("MAGIC CANVAS")
                        .font(.system(size: 11, weight: .semibold, design: .serif))
                        .foregroundStyle(StudioPalette.mint)
                        .tracking(0.7)
                    Spacer()
                    Text("\(studio.designs.count) thiết kế đã lưu")
                        .font(.system(size: 11))
                        .foregroundStyle(StudioPalette.muted)
                }
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(Array(SampleTemplates.catalog.prefix(4))) { design in
                            NavigationLink {
                                WidgetEditorView(design: design.duplicate())
                            } label: {
                                SceneShowcaseCard(design: design, height: 164)
                                    .frame(width: 155)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { tools.refresh() }
    }

    private func heritagePreview(kind: LunarCardKind, title: String,
                                 width: CGFloat, height: CGFloat) -> some View {
        NavigationLink {
            LunarCalendarHomeView()
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                LunarCardView(kind: kind,
                              size: kind == .month ? .large : (width < 200 ? .small : .medium),
                              civil: today, appearance: lunarFamily.appearance,
                              upcomingEvents: events)
                    .frame(width: width, height: height)
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundStyle(StudioPalette.muted)
            }
            .frame(width: width)
        }
        .buttonStyle(.plain)
    }

    private func metric(_ title: String, value: String, glyph: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Image(glyph)
                    .resizable().scaledToFit().frame(width: 18, height: 18)
                Text(title)
                    .font(.system(size: 10))
                    .foregroundStyle(StudioPalette.muted)
                    .lineLimit(1)
            }
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.63)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
