//
//  WeekNumberWidget.swift
//  WeekNumberWidget
//
//  Created by Zsolt Kébel on 27/09/2020.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), weekNo:  weekNumber(of: Date()))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), weekNo: weekNumber(of: Date()))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {

        // Generate a timeline with one entry that refreshes at midnight.
        let currentDate = Date()
        let startOfDay = Calendar.current.startOfDay(for: currentDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let entry = SimpleEntry(date: startOfDay, weekNo: weekNumber(of: startOfDay))
        let timeline = Timeline(entries: [entry], policy: .after(endOfDay))
        completion(timeline)
    }
    
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//
//        var components = DateComponents()
//        components.hour = 0
//        components.minute = 0
//        let date = Calendar.current.date(from: components) ?? Date()
//
//        for hourOffset in 0 ..< 7 {
//
//            let entryDate = Calendar.current.date(byAdding: .day, value: hourOffset, to: date)!
//
//            let entry = SimpleEntry(date: entryDate, weekNo: weekNumber(of: entryDate))
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let weekNo: Int
}

struct WeekNumberWidgetEntryView : View {
    var entry: Provider.Entry

    @State var progressValue: Float = 3 / 7

    var body: some View {
        VStack(alignment: .leading, spacing: nil, content: {
//            Text(entry.date, style: .time)
            Text("WEEK NUMBER")
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.gray)
                .fontWeight(.light)
//                .frame(maxWidth: .infinity)
            Spacer()
            Text("\(weekNumber(of: entry.date))")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.light)
//                .frame(maxWidth: .infinity)
            Spacer()
            Text(dateString())
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.blue)
//            ProgressBar(value: $progressValue)
//                .frame(height: 6)
            WeekIndicator(dayOfWeek: dayOfWeek())
        })
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))

    }
}

@main
struct WeekNumberWidget: Widget {
    let kind: String = "WeekNumberWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeekNumberWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct WeekNumberWidget_Previews: PreviewProvider {
    static var previews: some View {
        WeekNumberWidgetEntryView(entry: SimpleEntry(date: Date(), weekNo: weekNumber(of: Date())))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

func days(from: Date, to: Date) -> Int {
    let diff = Calendar.current.dateComponents([.day], from: from, to: to)
    
    return diff.day ?? 4
}

func dateString() -> String {
    let components = Calendar.current.dateComponents([.day, .month], from: Date())
    let day = components.day ?? 0
    let month = components.month ?? 0
    
    return "\(day) \(getMonth(month: month))"
}

func weekNumber(of: Date) -> Int {
    let startDate = UserDefaults(suiteName: "group.com.zsoltkebel.Week-Number.contents")?.value(forKey: "startDateKey") as? Date ?? Date()
    
    let diff = days(from: startDate, to: of)
    
    return diff / 7
}

func getMonth(month: Int) -> String {
    switch month {
    case 1:
        return "January"
    case 2:
        return "February"
    case 3:
        return "March"
    case 4:
        return "April"
    case 5:
        return "May"
    case 6:
        return "June"
    case 7:
        return "July"
    case 8:
        return "August"
    case 9:
        return "September"
    case 10:
        return "October"
    case 11:
        return "November"
    case 12:
        return "December"
    default:
        return ""
    }
}

func dayOfWeek() -> Int {
    let weekDay = Calendar.current.dateComponents([.weekday], from: Date())
    
    return weekDay.weekday == 1 ? 7 : weekDay.weekday! - 1
}


// custom view
struct ProgressBar: View {
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(.linear)
                    .cornerRadius(geometry.size.height / 2)
            }.cornerRadius(geometry.size.height / 2)
        }
    }
}

struct WeekIndicator: View {
    var dayOfWeek: Int
    
    let days: [String] = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center) {
                ForEach(0..<days.count, id: \.self) { index in
                    let selected = index == dayOfWeek - 1
                    if (selected) {
                    Text(days[index])
                        .foregroundColor(Color(selected ? UIColor.systemBlue : UIColor.systemTeal))
                        .font(.system(size: selected ? 18.0 : 12.0, weight: selected ? .bold : .bold, design: .rounded))
                        .opacity(selected ? 1.0 : 0.4)
//                        .frame(maxWidth: .infinity)
                    } else {
                        Circle()
                            .foregroundColor(Color(UIColor.systemTeal))
                            .opacity(0.3)
                            .frame(width: 7.0, height: 7.0)
                    }
                    if (index < days.count - 1) {
                        Spacer()
                    }
                }
            }.frame(maxWidth: .infinity)
        }
    }
}
