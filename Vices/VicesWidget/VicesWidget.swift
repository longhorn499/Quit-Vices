//
//  VicesWidget.swift
//  VicesWidget
//
//  Created by Kevin Johnson on 10/6/21.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> VicesEntry {
        VicesEntry(
            vices: [],
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (VicesEntry) -> ()) {
        let entry = VicesEntry(
            vices: [],
            configuration: ConfigurationIntent()
        )
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries: [VicesEntry] = [
            .init(date: .todayMonthDayYear(), vices: loadVices(), configuration: configuration)
        ]
        let timeline = Timeline(
            entries: entries,
            policy: .atEnd
        )
        completion(timeline)
    }

    // MARK: - Helper

    private func loadVices() -> [Vice] {
        let url = AppGroup.vices.containerURL.appendingPathComponent("vices")
        do {
            let data = try Data(contentsOf: url)
            let vices = try JSONDecoder().decode([Vice].self, from: data)
            return vices
        } catch {
            print("couldn't load vices:", error)
            print("could just not be cached yet, so return empty")
            return []
        }
    }
}

// MARK: - VicesEntry

struct VicesEntry: TimelineEntry {
    let date: Date
    let vices: [Vice]
    let configuration: ConfigurationIntent

    init(
        date: Date = .todayMonthDayYear(),
        vices: [Vice],
        configuration: ConfigurationIntent
    ) {
        self.date = date
        self.vices = vices
        self.configuration = configuration
    }
}

// MARK: - VicesWidgetEntryView

struct VicesWidgetEntryView : View {
    var entry: Provider.Entry
    let prefix: Int = 3

    var body: some View {
        ZStack {
            Color(.secondarySystemGroupedBackground)
                .ignoresSafeArea()
            if entry.vices.isEmpty {
                Text("No Vices").bold()
            } else {
                VStack(alignment: .leading, spacing: 4.0) {
                    ForEach(entry.vices.prefix(prefix), id: \.self) { vice in
                        Text("\(vice.name)")
                            .font(.caption)
                            .bold()
                        Text("\(Formatters.quittingDay(vice.quittingDate))")
                            .font(.caption)
                    }
                    Spacer()
                    entry.vices.count > prefix ?
                    Text("+\(entry.vices.count - entry.vices.prefix(prefix).count) more")
                        .font(.caption2): nil
                    Spacer()
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.horizontal)
                .padding(.top)
            }
        }
    }
}

// MARK: - VicesWidget

@main
struct VicesWidget: Widget {
    let kind: String = "VicesWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            VicesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Current Vices")
        .description("Show the list of vices")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Previews

struct VicesWidget_Previews: PreviewProvider {
    static var previews: some View {
        VicesWidgetEntryView(
            entry: VicesEntry(
                date: Date.todayMonthDayYear(),
                vices: [
                    .init(name: "Smoking", reason: nil),
                    .init(name: "Drinking", reason: nil),
                    .init(name: "Test", reason: nil)
                ],
                configuration: ConfigurationIntent()
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
