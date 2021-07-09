//
//  widget.swift
//  widget
//
//  Created by Jonas Kaiser on 18.04.21.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), seconds_left: 0, minutes_left: 0, hours_left: 0, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), seconds_left: 0, minutes_left: 0, hours_left: 0, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let sec_left = 0
        let min_left = 0
        let h_left = 0
        for offset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .second, value: offset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, seconds_left: (sec_left - offset) % 60, minutes_left: (min_left - offset) % 60, hours_left: (h_left - offset) % 24, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    
    let seconds_left: Int
    let minutes_left: Int
    let hours_left: Int
    let configuration: ConfigurationIntent
}

struct widgetEntryView : View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemLarge: CircleView(entry: entry)
        case .systemSmall: SmallTextView(entry: entry)
        case .systemMedium: MediumTextView(entry: entry)
        @unknown default:
            fatalError()
        }
        
    }
}

struct CircleView: View {
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            Text(String(format: "%02d:%.02d:%02d", entry.hours_left, entry.minutes_left, entry.seconds_left))
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.custom("SF Pro Display", size: 24))
        }
    }
}

struct SmallTextView: View {
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            Text(String(format: "%02d:%.02d:%02d", entry.hours_left, entry.minutes_left, entry.seconds_left))
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.custom("SF Pro Display", size: 24))
        }
    }
}

struct MediumTextView: View {
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            Text(String(format: "%02d:%.02d:%02d", entry.hours_left, entry.minutes_left, entry.seconds_left))
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.custom("SF Pro Display", size: 40))
        }
    }
}

@main
struct widget: Widget {
    let kind: String = "timer"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct widget_Previews: PreviewProvider {
    static var previews: some View {
        widgetEntryView(entry: SimpleEntry(date: Date(), seconds_left: 0, minutes_left: 0, hours_left: 0, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        widgetEntryView(entry: SimpleEntry(date: Date(), seconds_left: 0, minutes_left: 0, hours_left: 0, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        
        widgetEntryView(entry: SimpleEntry(date: Date(), seconds_left: 0, minutes_left: 0, hours_left: 0, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))

    }
}
