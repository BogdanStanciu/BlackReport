//
//  ThemePickerView.swift
//  BlackReport
//
//  Created by Bogdan Stanciu on 05/11/2026.
//

import SwiftUI

/// Lista dei colori tema: tocca una riga per applicarlo subito.
struct ThemePickerView: View {
    @AppStorage(AppTheme.storageKey) private var themeRaw = AppTheme.red.rawValue
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(AppTheme.allCases) { theme in
                Button {
                    themeRaw = theme.rawValue
                } label: {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(theme.color)
                            .frame(width: 28, height: 28)
                        Text(theme.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        if theme.rawValue == themeRaw {
                            Image(systemName: "checkmark")
                                .fontWeight(.semibold)
                                .foregroundStyle(theme.color)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
