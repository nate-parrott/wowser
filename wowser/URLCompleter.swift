//
//  URLCompleter.swift
//  wowser
//
//  Created by Nate Parrott on 4/26/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation

class URLCompleter {
    // MARK: Globals
    static func defaultURL() -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        return URL(fileURLWithPath: path)
    }
    static let shared = URLCompleter(url: defaultURL())
    
    // MARK: Lifecycle
    init(url: URL) {
        self.url = url
        load()
        startSaveTimer()
    }
    
    let url: URL
    
    func startSaveTimer() {
        let interval: Double = 2 * 60 // every 5 mins
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
            self?.startSaveTimer()
        }
    }
    
    // MARK: Saving and restoring
    var needsSave = false
    
    func load() {
        if let data = try? Data(contentsOf: url),
            let jsonObj = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonDict = jsonObj as? [String: Any] {
            // TODO
        }
    }
    
    func save() {
        
    }
    
    // MARK: API
    struct Page {
        let title: String
        let url: URL
    }
    struct PageLoad {
        let page: Page
        let wasDirectlyTyped: Bool
        var scoreContribution: Double {
            get {
                return wasDirectlyTyped ? 10 : 1
            }
        }
    }
    struct Completion {
        let page: Page
    }
    func recordPageLoad(load: PageLoad) {
        
    }
    func trackResultsOfCompletion(completions: [Completion], selected: Completion?) {
        
    }
//    func autocomplete(query: String) -> [Completion] {
//        
//    }
    // MARK: Internal data structures
    struct Entry {
        let title: String!
        let url: URL
        let score: Double
        
        func withScore(score: Double) -> Entry {
            return Entry(title: title, url: url, score: score)
        }
        
        func decayed(time: TimeInterval) -> Entry {
            let decayPerDay = 0.5
            let days = time / (60 * 60 * 24)
            let decay = pow(decayPerDay, days)
            return withScore(score: score * decay)
        }
        
//        func withPageLoadRecorded(pageLoad: PageLoad) -> Entry {
//            
//        }
    }
}

extension URL {
    var hostRoot: URL {
        get {
            var comps = URLComponents(url: normalized, resolvingAgainstBaseURL: false)!
            comps.path = ""
            return comps.url!
        }
    }
    var isHostRoot: Bool {
        get {
            return normalized == hostRoot
        }
    }
    var normalized: URL {
        get {
            // rules for URL comparison:
            // http://stackoverflow.com/questions/5801580/how-to-compare-two-nsurls-that-are-practically-equivalent-but-have-cosmetic-stri
            var comps = URLComponents(url: self, resolvingAgainstBaseURL: false)!
            comps.scheme = comps.scheme?.lowercased()
            comps.host = comps.host?.lowercased()
            // strip trailing slashes:
            let path = comps.path
            if path != "" {
                let lastCharIdx = path.index(before: path.endIndex)
                let lastChar = path[lastCharIdx]
                let slash: Character = "/"
                if lastChar == slash {
                    comps.path = path.substring(to: lastCharIdx)
                }
            }
            return comps.url!
        }
    }
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

