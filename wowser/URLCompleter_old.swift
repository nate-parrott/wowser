////
////  URLCompleter.swift
////  wowser
////
////  Created by Nate Parrott on 4/26/17.
////  Copyright © 2017 Nate Parrott. All rights reserved.
////
//
//import Foundation
//import SortedSet
//
//class URLCompleter_old {
//    // MARK: Globals
//    static func defaultURL() -> URL {
//        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
//        return URL(fileURLWithPath: path)
//    }
//    static let shared = URLCompleter(url: defaultURL())
//    
//    // MARK: Lifecycle
//    init(url: URL) {
//        self.url = url
//        load()
//        startSaveTimer()
//    }
//    
//    let url: URL
//    
//    func startSaveTimer() {
//        let interval: Double = 2 * 60 // every 5 mins
//        DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
//            self?.startSaveTimer()
//        }
//    }
//    
//    // MARK: Saving and restoring
//    var needsSave = false
//    
//    func load() {
//        if let data = try? Data(contentsOf: url),
//            let jsonObj = try? JSONSerialization.jsonObject(with: data, options: []),
//            let jsonDict = jsonObj as? [String: Any] {
//            // TODO
//        }
//    }
//    
//    func save() {
//        
//    }
//    
//    // MARK: API
//    struct Page {
//        let title: String
//        let url: URL
//        init(title: String, url: URL) {
//            self.title = title
//            self.url = url.normalized
//        }
//    }
//    struct Completion {
//        let page: Page
//    }
//    // MARK: API - activity tracking
//    func recordPageLoad(page: Page) {
//        if page.url == lastDirectURLEntered {
//            // we directly typed this url -- we should record it
//            
//        }
//    }
//    private var lastDirectURLEntered: URL?
//    func recordDirectURLEntry(url: URL) {
//        lastDirectURLEntered = url.normalized
//    }
//    func recordCompletionResult(completions: [Completion], selected: Completion?) {
//        
//    }
//    func recordTabExpired(page: Page) {
//        
//    }
//    // MARK: API - completions
////    func autocomplete(query: String) -> [Completion] {
////        
////    }
//    // MARK: Internal data structures
////    private var entriesSorted = SortedSet<Entry>()
////    private var entriesByUrl = [URL: Entry]()
////    func addScoreForPage(page: Page, score: Double) {
////        let entry = entriesByUrl[page.url] ?? Entry(title: page.title, url: page.url, score: 0)
////        entry.score += score
////        entryHeap.ind
////    }
////    class Entry: Comparable {
////        init(title: String, url: URL, score: Double) {
////            self.title = title
////            self.url = url.normalized
////            self.score = score
////        }
////        
////        let title: String!
////        let url: URL
////        let score: Double
////        
////        func withScore(score: Double, title: String?) -> Entry {
////            return Entry(title: title ?? self.title, url: url, score: score)
////        }
////        
////        func decayed(time: TimeInterval) -> Entry {
////            let decayPerDay = 0.5
////            let days = time / (60 * 60 * 24)
////            let decay = pow(decayPerDay, days)
////            return withScore(score: score * decay, title: nil)
////        }
////        
////        var hashValue: Int {
////            return url.absoluteString.hashValue
////        }
////    }
//}
//
//
////func < (lhs: URLCompleter.Entry, rhs: URLCompleter.Entry) -> Bool {
////    return lhs.url.absoluteString < rhs.url.absoluteString
////}
////
////func == (lhs: URLCompleter.Entry, rhs: URLCompleter.Entry) -> Bool {
////    return lhs.url.absoluteString == rhs.url.absoluteString
////}
//
