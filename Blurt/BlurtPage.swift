//
//  BlurtPage.swift
//  Blurt
//
//  Created by Tomislav Mijatovic on 17.01.26.
//

import Foundation

struct BlurtPage: Codable, Identifiable {
    let id: UUID
    var text: AttributedString // Änderung: text ist jetzt AttributedString

    // Neuer Initializer mit optionalem AttributedString, Standard ist leeres AttributedString
    init(id: UUID = UUID(), text: AttributedString = AttributedString()) {
        self.id = id
        self.text = text
    }

    // Zusätzlicher Initializer mit String, der in AttributedString konvertiert wird
    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = AttributedString(text)
    }

    // Explizite Codable-Konformität, da AttributedString Codable unterstützt
    enum CodingKeys: CodingKey {
        case id, text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(AttributedString.self, forKey: .text)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
    }
}
