//
//  ContentView.swift
//  Blurt
//
//  Created by Tomislav Mijatovic on 15.01.26.
//

import SwiftUI
import Combine

struct ContentView: View {

    @StateObject private var store = BlurtStore()
    @FocusState private var focused: Bool
    @Environment(\.scenePhase) private var scenePhase

    // Toast / Undo
    @State private var toastText: String?
    @State private var deleted: (page: BlurtPage, index: Int)?

    // Debounced save
    @State private var saveWorkItem: DispatchWorkItem?

    var body: some View {
        NavigationStack {
            ZStack {
                // Pages
                TabView(selection: $store.index) {
                    ForEach(Array(store.pages.enumerated()), id: \.1.id) { i, page in
                        TextEditor(text: $store.pages[i].text)
                            .font(.system(size: 17, weight: .regular, design: .monospaced))
                            .focused($focused)
                            .padding()
                            .tag(i)

                    }
                }
                .tabViewStyle(.page)

                // Toast
                if let toastText {
                    VStack {
                        Spacer()
                        ToastView(
                            text: toastText,
                            undo: deleted.map { _ in undoDelete }
                        )
                        .padding(.bottom, 40)
                    }

                    .task(id: toastText) {
                        try? await Task.sleep(for: .seconds(5))
                        if self.toastText == toastText {
                            withAnimation {
                                self.toastText = nil
                                self.deleted = nil
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {

                    Button {
                        withAnimation {
                            switch store.deletePage() {
                            case .deleted(let page, let index):
                                deleted = (page, index)
                                toastText = "Page deleted"
                            case .clearedSinglePage:
                                toastText = nil
                                deleted = nil
                            case .cannotDeleteLastPage:
                                toastText = "You must keep at least one page"
                                deleted = nil
                            }
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }


                    // New Page
                    Button {
                        let created = store.addPage()
                        if created {
                            DispatchQueue.main.async {
                                focused = true
                            }
                        } else {
                            withAnimation {
                                toastText = "Already on a new page"
                                deleted = nil
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("Blurt")
            .navigationBarTitleDisplayMode(.inline)
        }
        // Shake = Undo
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
            undoDelete()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                store.save()
            }
        }
        .onChange(of: store.index) { _ in
            store.save()
        }
        // Debounced save on text changes (idle-based)
        .onChange(of: store.pages.indices.contains(store.index) ? store.pages[store.index].text : "") { _ in
            // Cancel any pending save
            saveWorkItem?.cancel()

            // Schedule a new save after short idle
            let work = DispatchWorkItem { store.save() }
            saveWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: work)
        }
    }

    // MARK: - Undo
    private func undoDelete() {
        if let deleted {
            store.insert(deleted.page, at: deleted.index)
            withAnimation {
                self.deleted = nil
                self.toastText = nil
            }
        }
    }
}

#Preview {
    ContentView()
}

