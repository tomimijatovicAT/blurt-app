//
//  ToastView.swift
//  Blurt
//
//  Created by Tomislav Mijatovic on 17.01.26.
//

import SwiftUI

struct ToastView: View {
    let text: String
    let undo: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Text(text)
                .font(.system(.footnote, design: .monospaced))
                .foregroundColor(.white)

            if let undo {
                Button("Undo", action: undo)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
        }
        .font(.footnote)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.black.opacity(0.85))
        .cornerRadius(12)
    }
}
