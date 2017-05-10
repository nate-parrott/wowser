//
//  URLCompleterTests.swift
//  wowser
//
//  Created by Nate Parrott on 5/4/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation

class URLCompleterTests : NSObject {
    @objc static func testAll() {
        testURLMethods()
        // testAutocompletes()
        testURLTypingCompletions()
    }
    static func testURLMethods() {
        let root = URL(string: "http://nateparrott.com")!
        let stillRoot = URL(string: "HTTP://NATEPARROTT.com/")!
        let notRoot = URL(string: "http://nateparrott.com/page")!
        assert(root.normalized == stillRoot.normalized)
        assert(root.isHostRoot)
        assert(stillRoot.isHostRoot)
        assert(!notRoot.isHostRoot)
        print("testURLMethods passed!")
    }
    static func testAutocompletes() {
        LoadSearchAutocompletes(query: "he") {
            (items) in
            if let i = items {
                print("\(i)")
            } else {
                print("no autocompletes")
            }
        }
    }
    static func testURLTypingCompletions() {
        let entry = URLCompleterDataStore.Entry(url: URL(string: "http://www.google.com/xyz")!)
        entry.title = "Google"
        assert(entry.potentialTypingCompletions().contains("google.com/xyz"))
        assert(entry.potentialTypingCompletions().contains("Google"))
        assert(entry.potentialTypingCompletions().contains("www.google.com/xyz"))
    }
}
