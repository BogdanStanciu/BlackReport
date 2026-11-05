//
//  AppLanguage.swift
//  BlackReport
//
//  Created by bogdan.stanciu on 03/11/26.
//

import Foundation
 
/// Lingue supportate dall'app e scelta salvata dall'utente.
enum AppLanguage: String, CaseIterable, Identifiable {
    case italian = "it"
    case english = "en"
 
    static let storageKey = "app_language"
 
    var id: String { rawValue }
 
    var displayName: String {
        switch self {
        case .italian: return "Italiano"
        case .english: return "English"
        }
    }
 
    static var deviceDefault: AppLanguage {
        Locale.preferredLanguages.first?.hasPrefix("it") == true ? .italian : .english
    }
}
 
