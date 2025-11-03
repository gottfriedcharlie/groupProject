//
//  Date+Formatting.swift
//  groupProject
//
//   .
//
import Foundation

extension Date {
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
    
    var isInPast: Bool {
        self < Date()
    }
    
    var isInFuture: Bool {
        self > Date()
    }
}
