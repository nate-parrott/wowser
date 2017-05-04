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
        // url must be normalized
        
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
        
        decayAndCleanIfNeeded()
        
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


