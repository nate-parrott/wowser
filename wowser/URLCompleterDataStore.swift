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
    
    func addTitleForPage(url: URL, title: String) {
        entriesByUrl[url]?.title = title
    }
    
    private let preferredSize = 1000
    private let maxExtraSize = 300
    private let timeThresholdForDecay: CFAbsoluteTime = 5 * 60 * 60 // every 5 hours
    
    func decayAndCleanIfNeeded() {
        if entriesByScore.count > preferredSize + maxExtraSize || CFAbsoluteTimeGetCurrent() - lastCleanTime >= timeThresholdForDecay {
            decayAndClean()
        }
    }
    
    func decayAndClean() {
        let maxSize = preferredSize + maxExtraSize
        let nEntriesToCut = max(0, entriesByScore.count - maxSize)
        for _ in 0..<nEntriesToCut {
            if let entry = entriesByScore.first {
                _ = entriesByScore.remove(entry)
                entriesByUrl.removeValue(forKey: entry.url)
            }
        }
        let decayPerDay = 0.5
        let days = lastCleanTime / (60 * 60 * 24)
        let decay = pow(decayPerDay, days)
        for item in entriesByScore {
            item.score *= decay
        }
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
            var completions = [url.absoluteString]
            var str = url.absoluteString
            for prefix in ["https://", "http://", "www."] {
                if str.lowercased().hasPrefix(prefix) {
                    str = str.byRemovingPrefix(prefix)
                    completions.append(str)
                }
            }
            if let t = title { completions.append(t) }
            return completions
        }
    }
    
    // MARK: Internal data
    var lastCleanTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    var additionsSinceLastClean = 0
    var entriesByScore = SortedSet<Entry>()
    var entriesByUrl = [URL: Entry]()
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

//extension URL {
//    func hasFuzzyPrefix(_ prefix: String) -> Bool {
//        let prefixLowercased = prefix.lowercased()
//        var str = absoluteString.lowercased()
//        if str.hasPrefix(prefixLowercased) {
//            return true
//        }
//        for stripPrefix in ["https://", "http://", "www."] {
//            if str.hasPrefix(stripPrefix) {
//                str = str.substring(from: str.index(str.startIndex, offsetBy: stripPrefix.characters.count))
//                if str.hasPrefix(prefixLowercased) {
//                    return true;
//                }
//            }
//        }
//        return false
//    }
//}

extension String {
    func byRemovingPrefix(_ prefix: String) -> String {
        return substring(from: index(startIndex, offsetBy: prefix.characters.count))
    }
}

