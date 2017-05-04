//
//  URLCompleter.swift
//  wowser
//
//  Created by Nate Parrott on 5/3/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation
import SortedSet

@objc class URLCompleter: NSObject {
    @objc static let shared = URLCompleter()
    
    private let _dataStore = URLCompleterDataStore()
    
    // MARK: API
    @objc func recordPageLoad(url: URL, title: String) {
        let normalizedUrl = url.normalized
        let wasDirectlyTyped = (normalizedUrl == _lastDirectlyTypedURL)
        _dataStore.performAsyncWithLock {
            if wasDirectlyTyped {
                self._dataStore.addScoreForPage(url: normalizedUrl, score: 10)
            }
            self._dataStore.addScoreForPage(url: url.hostRoot, score: 10)
            self._dataStore.addTitleForPage(url: normalizedUrl, title: title)
        }
    }
    
    private var _lastDirectlyTypedURL: URL?
    func recordDirectlyTypedURL(url: URL) {
        _lastDirectlyTypedURL = url.normalized
    }
    
    // MARK: Private storage functions
    
}

