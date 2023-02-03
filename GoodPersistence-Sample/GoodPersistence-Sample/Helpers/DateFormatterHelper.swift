//
//  DateFormatter.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import Foundation

enum DateFormat: String {

    case hhmmss = "HH:mm:ss"
}

final class DateFormatterHelper {

    public static let shared = DateFormatterHelper()
    public let formatter: DateFormatter

    private init() {
        self.formatter = DateFormatter()
    }

    func formatDateToString(date: Date, dateFormat: DateFormat) -> String? {
        formatter.dateFormat = dateFormat.rawValue

        return formatter.string(from: date)
    }

}
