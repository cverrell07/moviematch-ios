//
//  Extension.swift
//  moviematch
//
//  Created by Christopher Verrell on 14/03/26.
//

import UIKit

extension UIColor {
    static let appBackground = UIColor(
        red: 26/255,
        green: 26/255,
        blue: 26/255,
        alpha: 1
    )
}

extension String {
    func formattedDate() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: self) else { return self }

        let relative = RelativeDateTimeFormatter()
        relative.unitsStyle = .full
        return relative.localizedString(for: date, relativeTo: Date())
    }
}
