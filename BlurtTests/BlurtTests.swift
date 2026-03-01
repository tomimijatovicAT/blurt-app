//
//  BlurtTests.swift
//  BlurtTests
//
//  Created by Tomislav Mijatovic on 17.01.26.
//

import XCTest
@testable import Blurt

@MainActor
final class BlurtStoreTests: XCTestCase {

    var store: BlurtStore!

    override func setUp() {
        super.setUp()
        store = BlurtStore()
        store.pages = [BlurtPage(text: "Test")]
        store.index = 0
    }

    override func tearDown() {
        store = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testStoreStartsWithOnePage() {
        let freshStore = BlurtStore()
        XCTAssertEqual(freshStore.pages.count, 1)
    }

    // MARK: - Add Page

    func testAddPageWithContentCreatesNewPage() {
        store.addPage()
        XCTAssertEqual(store.pages.count, 2)
        XCTAssertEqual(store.index, 1)
    }

    func testAddPageWithEmptyContentDoesNothing() {
        store.pages[0].text = ""
        store.addPage()
        XCTAssertEqual(store.pages.count, 1)
    }

    // MARK: - Delete Page

    func testDeleteSinglePageWithContentClearsText() {
        let result = store.deletePage()

        if case .clearedSinglePage = result {
            XCTAssertEqual(store.pages.count, 1)
            XCTAssertEqual(store.pages[0].text, "")
        } else {
            XCTFail("Expected clearedSinglePage")
        }
    }

    func testDeleteSingleEmptyPageShowsError() {
        store.pages[0].text = ""
        let result = store.deletePage()

        if case .cannotDeleteLastPage = result {
            XCTAssertEqual(store.pages.count, 1)
        } else {
            XCTFail("Expected cannotDeleteLastPage")
        }
    }

    func testDeleteMultiplePagesRemovesPage() {
        store.pages.append(BlurtPage(text: "Second"))
        store.index = 1

        let result = store.deletePage()

        if case .deleted(let page, _) = result {
            XCTAssertEqual(page.text, "Second")
            XCTAssertEqual(store.pages.count, 1)
        } else {
            XCTFail("Expected deleted")
        }
    }

    // MARK: - Undo Insert

    func testInsertRestoresPage() {
        let page = BlurtPage(text: "Undo me")
        store.insert(page, at: 0)

        XCTAssertEqual(store.pages.count, 2)
        XCTAssertEqual(store.pages[0].text, "Undo me")
    }
}
