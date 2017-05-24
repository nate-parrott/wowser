//
//  URLCompleterDataStore.swift
//  wowser
//
//  Created by Nate Parrott on 5/4/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation
import SortedSet

class URLCompleterDataStore {
    private let lock = NSLock()
    
    func performAsyncWithLock(fn: @escaping (() -> ())) {
        DispatchQueue.global(qos: .background).async {
            self.lock.lock()
            fn()
            self.lock.unlock()
        }
    }
    
    // these methods MUST be called from inside performAsyncWithLock
    
    func addScoreForPage(url: URL, score: Double) {
        print("adding score for url: \(url)")
        // url must be normalized by caller
        
        decayAndCleanIfNeeded()
        
        var entry: Entry!
        if let existing = entriesByUrl[url] {
            entry = existing
            _ = entriesByScore.remove(entry)
        } else {
            entry = Entry(url: url)
            entriesByUrl[url] = entry
        }
        entry.score += score
        entriesByScore.insert(entry)
        
        let c = entriesByScore.count
        print("\(c) entries now")
    }
    
    func addAltURLs(_ alt: [URL], forPage: URL) {
        if let entry = entriesByUrl[forPage.normalized] {
            for url in alt {
                entry.alternateURLs.insert(url.normalized)
            }
        }
    }
    
    func addTitleForPage(url: URL, title: String) {
        print("title: \(title) for page: \(url)")
        entriesByUrl[url]?.title = title
    }
    
    private var preferredSize = 1000
    private let maxExtraSize = 300
    private let timeThresholdForDecay: CFAbsoluteTime = 5 * 60 * 60 // every 5 hours
    
    func decayAndCleanIfNeeded() {
        if entriesByScore.count > preferredSize + maxExtraSize || CFAbsoluteTimeGetCurrent() - lastCleanTime >= timeThresholdForDecay {
            decayAndClean()
        }
    }
    
    func decayAndClean() {
        let nEntriesToCut = max(0, entriesByScore.count - preferredSize)
        for _ in 0..<nEntriesToCut {
            if let entry = entriesByScore.first {
                _ = entriesByScore.remove(entry)
                entriesByUrl.removeValue(forKey: entry.url)
            }
        }
        let decayPerDay = 0.5
        let days = (CFAbsoluteTimeGetCurrent() - lastCleanTime) / (60 * 60 * 24)
        let decay = pow(decayPerDay, days)
        for item in entriesByScore {
            item.score *= decay
        }
        lastCleanTime = CFAbsoluteTimeGetCurrent()
    }
    
    func search(query: String) -> [Entry] {
        let lowercaseQuery = query.lowercased()
        return entriesByScore.filter({ $0.matches(search: lowercaseQuery) })
    }
    
    // MARK: Entries
    class Entry: Comparable, Hashable {
        init(url: URL) {
            self.url = url.normalized
        }
        var score = 0.0
        var title: String?
        var url: URL
        var alternateURLs = Set<URL>()
        var hashValue: Int {
            return url.absoluteString.hashValue
        }
        func matches(search: String) -> Bool {
            if let t = title, t.lowercased().hasPrefix(search) {
                return true
            }
            for str in potentialTypingCompletions() {
                if str.lowercased().hasPrefix(search) {
                    return true
                }
            }
            return false
        }
        func potentialTypingCompletions() -> [String] {
            var completions = (Array(alternateURLs) + [url]).flatMap({$0.typeaheadStrings()})
            if let t = title { completions.append(t) }
            return completions
        }
        func toJson() -> [String: Any] {
            return ["url": url.absoluteString, "title": title ?? NSNull(), "score": score, "alternateURLs": alternateURLs.map({ $0.absoluteString })]
        }
        static func fromJson(_ json: [String: Any]) -> Entry? {
            if let urlString = json["url"] as? String,
                let url = URL(string: urlString),
                let score = json["score"] as? Double {
                let entry = Entry(url: url)
                entry.score = score
                entry.title = json["title"] as? String
                let altURLStrings = (json["alternateURLs"] as? [String]) ?? [String]()
                entry.alternateURLs = Set(altURLStrings.flatMap({URL(string: $0)}))
                return entry
            } else {
                return nil
            }
        }
    }
    
    // MARK: Internal data
    var lastCleanTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    var entriesByScore = SortedSet<Entry>()
    var entriesByUrl = [URL: Entry]()
    
    // MARK: Serialization
    func toJson() -> [String: Any] {
        var d = [String: Any]()
        d["entries"] = entriesByScore.map({ $0.toJson() })
        return d
    }
    
    static func fromJson(_ json: [String: Any]) -> URLCompleterDataStore? {
        let store = URLCompleterDataStore()
        if let entryJson = json["entries"] as? [[String: Any]] {
            for entry in entryJson.flatMap({ Entry.fromJson($0) }) {
                store.entriesByScore.insert(entry)
                store.entriesByUrl[entry.url] = entry
            }
        }
        store.decayAndClean()
        return store
    }
    
    // MARK: Testing
    static func test() {
        let ds = URLCompleterDataStore()
        ds.performAsyncWithLock {
            ds.addScoreForPage(url: URL(string: "http://google.com")!, score: 2)
            ds.addScoreForPage(url: URL(string: "http://google.com")!, score: 3)
            ds.addScoreForPage(url: URL(string: "http://facebook.com")!, score: 3)
            assert(ds.entriesByScore.count == 2)
            assert(ds.entriesByScore.first!.url == URL(string: "http://facebook.com")!)
            assert(ds.entriesByScore.last!.score == 5)
            assert(ds.entriesByScore.first! == ds.entriesByUrl[URL(string: "http://facebook.com")!])
            
            ds.preferredSize = 1
            ds.decayAndClean()
            assert(ds.entriesByScore.count == 1)
            assert(ds.entriesByScore.first!.score > 0)
            assert(ds.entriesByUrl.count == 1)
            
            ds.preferredSize = 100
            
            ds.addScoreForPage(url: URL(string: "http://apple.com")!, score: 1)
            assert(ds.entriesByScore.count == 2)
            
            ds.addAltURLs([URL(string: "http://google.co.uk")!], forPage: URL(string: "http://google.com")!)
            
            let serialized = try! JSONSerialization.data(withJSONObject: ds.toJson(), options: [])
            let ds2 = URLCompleterDataStore.fromJson(try! JSONSerialization.jsonObject(with: serialized, options: []) as! [String: Any])!
            assert(ds2.entriesByUrl.count == 2)
            assert(ds2.entriesByScore.first!.url == URL(string: "http://apple.com")!)
            assert(ds2.entriesByUrl[URL(string: "http://google.com")!]!.alternateURLs.contains(URL(string: "http://google.co.uk")!))
        }
    }
}


func < (lhs: URLCompleterDataStore.Entry, rhs: URLCompleterDataStore.Entry) -> Bool {
    if lhs.score < rhs.score {
        return true
    } else if lhs.score > rhs.score {
        return false
    } else {
        return lhs.url.absoluteString < rhs.url.absoluteString
    }
}

func == (lhs: URLCompleterDataStore.Entry, rhs: URLCompleterDataStore.Entry) -> Bool {
    return lhs.score == rhs.score && lhs.url.absoluteString == rhs.url.absoluteString
}

extension String {
    func byRemovingPrefix(_ prefix: String) -> String {
        return substring(from: index(startIndex, offsetBy: prefix.characters.count))
    }
}

extension URL {
    func typeaheadStrings() -> [String] {
        var str = absoluteString
        var typeaheads = [str]
        for prefix in ["https://", "http://", "www."] {
            if str.lowercased().hasPrefix(prefix) {
                str = str.byRemovingPrefix(prefix)
                typeaheads.append(str)
            }
        }
        return typeaheads
    }
}

