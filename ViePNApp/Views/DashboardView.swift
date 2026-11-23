import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var studio: WidgetStudioStore
    @EnvironmentObject private var tools: UtilityStore

    var body: some View {
        StudioPage {
            VStack(alignment: .leading, spacing: 23) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("VIEPN / CREATIVE OS")
                            .font(.system(size: 10, weight: .bold)).tracking(2.5)
                            .foregroundStyle(StudioPalette.mint)
                        Text("Living Canvas.")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Make your screen feel alive.")
                            .font(.subheadline).foregroundStyle(StudioPalette.muted)
                    }
                    Spacer()
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.title2).foregroundStyle(StudioPalette.mint)
                        .frame(width: 49, height: 49)
                        .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 16))
                }
                StudioPanel {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HÔM NAY / LIFE OS")
                            .font(.system(size: 11, weight: .heavy)).tracking(1.7)
                            .foregroundStyle(StudioPalette.mint)
                        HStack(spacing: 12) {
                            metric("Ngân sách còn", value: tools.snapshot.revealOnWidgets ? tools.snapshot.remainingBudget().viepnVND : "••••••", icon: "creditcard")
                            metric("Việc cần làm", value: "\(tools.snapshot.pendingTasks.count) việc", icon: "checkmark.circle")
                        }
                        if let bill = tools.snapshot.nextUnpaidBill() {
                            Label("\(bill.name): còn \(bill.daysUntilDue(from: .now)) ngày", systemImage: "bell.badge")
                                .font(.caption).foregroundStyle(StudioPalette.muted)
                        }
                    }
                }
                NavigationLink {
                    WidgetEditorView(design: SampleTemplates.catalog[1].duplicate())
                } label: {
                    ZStack(alignment: .bottomLeading) {
                        LivingSceneView(scene: .cosmos, date: .now)
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("THE SIGNATURE COLLECTION")
                                    .font(.system(size: 10, weight: .black)).tracking(2)
                                    .foregroundStyle(StudioPalette.mint)
                                Text("Create your\nown universe.")
                                    .font(.system(size: 31, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.leading)
                                Label("Open Magic Canvas", systemImage: "arrow.up.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                    .background(.white.opacity(0.19), in: Capsule())
                            }
                            Spacer()
                        }
                        .padding(23)
                    }
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 27))
                }
                .buttonStyle(.plain)

                HStack {
                    Text("EXPLORE WORLDS")
                        .font(.system(size: 12, weight: .black)).tracking(2)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("6 SCENES").font(.caption.bold())
                        .foregroundStyle(StudioPalette.muted)
                }
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(LivingScene.allCases) { scene in
                            NavigationLink {
                                WidgetEditorView(design: WidgetDesign.fresh(.clock, scene: scene))
                            } label: {
                                ZStack(alignment: .bottomLeading) {
                                    LivingSceneView(scene: scene, date: .now)
                                    Text(scene.name)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(13)
                                }
                                .frame(width: 147, height: 153)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollIndicators(.hidden)

                StudioPanel {
                    HStack(spacing: 15) {
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.title2).foregroundStyle(StudioPalette.mint)
                            .frame(width: 54, height: 54)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 15))
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(studio.designs.count) saved creations")
                                .font(.headline).foregroundStyle(.white)
                            Text("Thế giới sáng tạo của riêng bạn")
                                .font(.caption).foregroundStyle(StudioPalette.muted)
                        }
                        Spacer()
                    }
                }
                HStack {
                    Text("CURATED FOR YOU")
                        .font(.system(size: 12, weight: .black)).tracking(2).foregroundStyle(.white)
                    Spacer()
                }
                ForEach(Array(SampleTemplates.catalog.prefix(3))) { design in
                    NavigationLink {
                        WidgetEditorView(design: design.duplicate())
                    } label: {
                        SceneShowcaseCard(design: design, height: 205)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { tools.refresh() }
    }

    private func metric(_ name: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(name, systemImage: icon).font(.system(size: 10)).foregroundStyle(StudioPalette.muted)
            Text(value).font(.system(size: 17, weight: .bold, design: .rounded))
                .lineLimit(1).minimumScaleFactor(0.6).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
