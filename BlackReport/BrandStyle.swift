//
//  BrandStyle.swift
//  BlackReport
//
//  Created by Bogdan Stanciu on 05/11/2026.
//

import SwiftUI

extension Color {
    static let brandRed = Color(red: 0.82, green: 0.25, blue: 0.23)
}

enum Brand {
    static let name = "Black Report"
}

extension View {
    func redTopBar() -> some View {
           self
               .navigationBarTitleDisplayMode(.inline)
               .toolbarBackground(Color.brandRed, for: .navigationBar)
               .toolbarBackground(.visible, for: .navigationBar)
               .toolbarColorScheme(.dark, for: .navigationBar)
               .toolbar {
                   ToolbarItem(placement: .topBarLeading) {
                       Text(verbatim: Brand.name)
                           .font(.system(size: 28, weight: .black))
                           .italic()
                           .foregroundStyle(.white)
                   }
               }
       }
    
    func redHeaderSheet(cornerRadius: CGFloat = 28) -> some View {
        self.clipShape(UnevenRoundedRectangle(topLeadingRadius: cornerRadius, topTrailingRadius: cornerRadius))
            .background(alignment: .top) {Color.brandRed.frame(height: cornerRadius + 12)}
    }
}
