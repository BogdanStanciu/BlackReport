//
//  AppTheme.swift
//  BlackReport
//
//  Created by Bogdan Stanciu on 05/11/2026.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case red, orange, green, teal, blue, purple, pink, graphite
    static let storageKey = "app_theme"
    
    var id: String {rawValue}
    var color: Color{
        switch self {
        case .red:      return Color(red: 0.82, green: 0.25, blue: 0.23)
        case .orange:   return Color(red: 0.93, green: 0.52, blue: 0.13)
        case .green:    return Color(red: 0.20, green: 0.60, blue: 0.35)
        case .teal:     return Color(red: 0.10, green: 0.58, blue: 0.62)
        case .blue:     return Color(red: 0.20, green: 0.42, blue: 0.85)
        case .purple:   return Color(red: 0.52, green: 0.32, blue: 0.80)
        case .pink:     return Color(red: 0.85, green: 0.30, blue: 0.55)
        case .graphite: return Color(red: 0.25, green: 0.27, blue: 0.30)
        }
    }
    
    var name: LocalizedStringKey {
        switch self {
        case .red:      return "Red"
        case .orange:   return "Orange"
        case .green:    return "Green"
        case .teal:     return "Teal"
        case .blue:     return "Blue"
        case .purple:   return "Purple"
        case .pink:     return "Pink"
        case .graphite: return "Graphite"
        }
    }
    
    static func from(_ rawValue: String) -> AppTheme {
        AppTheme(rawValue : rawValue) ?? .red
    }
}
