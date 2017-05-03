//
//  URLCompleter.swift
//  wowser
//
//  Created by Nate Parrott on 5/3/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation
import RealmSwift

class URLCompleterEntry: Object {
    dynamic var url: String = ""
    dynamic var title: String = ""
    
    // properties for querying as-you-type:
    dynamic var titleForSearch: String = "" // lowercased
    dynamic var urlForSearch: String = "" // lowercased, scheme and www. are stripped
    
    dynamic var score: Double = 0
    
    override static func indexedProperties() -> [String] {
        return ["url", "titleForSearch", "urlForSearch"]
    }
}

class URLCompleterState: Object {
    dynamic var insertionsSinceLastCleanup: Int = 0
    dynamic var timeOfLastCleanup: Double = 0
}

class URLCompleterTests : NSObject {
    @objc static func testAll() {
        testURLMethods()
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
}
