//
//  BlurtStore.swift
//  Blurt
//
//  Created by Tomislav Mijatovic on 15.01.26.
//

import Foundation
import Combine

@MainActor
final class BlurtStore: ObservableObject {

    @Published var pages: [BlurtPage] = []
    @Published var index: Int = 0

    private let key = "blurtPages"

    enum DeleteResult {
        case deleted(page: BlurtPage, index: Int)
        case clearedSinglePage
        case cannotDeleteLastPage
    }


    init() {
        load()
        if pages.isEmpty {
            pages = [BlurtPage()]
        }
    }

    @discardableResult
    func addPage() -> Bool {
        // If current page has no content, do not create another empty page
        if isEffectivelyEmpty(text: pages[index].text) {
            return false
        }
        pages.append(BlurtPage())
        index = pages.count - 1
        save()
        return true
    }

    @discardableResult
    func deletePage() -> DeleteResult {
        
        if pages.count == 1 {
            
            if !isEffectivelyEmpty(text: pages[0].text) {
                pages[0] = BlurtPage(text: AttributedString())
                save()
                return .clearedSinglePage
            } else {
                
                return .cannotDeleteLastPage
            }
        }

      
        let removed = pages.remove(at: index)
        index = max(0, index - 1)
        save()
        return .deleted(page: removed, index: index)
    }


    func insert(_ page: BlurtPage, at i: Int) {
        pages.insert(page, at: i)
        index = i
        save()
    }
    

    func save() {
        if let data = try? JSONEncoder().encode(pages) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }


    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([BlurtPage].self, from: data) {
            pages = saved
        }
    }
    
    private func isEffectivelyEmpty(text: AttributedString) -> Bool {
        text.characters.allSatisfy { $0.isWhitespace || $0.isNewline }
    }
}

