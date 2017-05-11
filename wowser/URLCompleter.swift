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
    
    @objc static let shared = URLCompleter(url: defaultURL())
    
    static func defaultURL() -> URL {
        FileManager.default.ensureAppSupportDirectoryExists()
        return FileManager.default.appSupportDirectory.appendingPathComponent("URLCompleter.shared.json")
    }
    
    private var _dataStore = URLCompleterDataStore()
    
    convenience override init() {
        self.init(url: nil)
    }
    
    init(url: URL?) {
        self.url = url
        super.init()
        if let aUrl = url,
            let data = try? Data(contentsOf: aUrl),
            let jsonObj = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonDict = jsonObj as? [String: Any],
            let dataStore = URLCompleterDataStore.fromJson(jsonDict) {
                _dataStore = dataStore
            print("restored url completer data from \(aUrl)")
        }
    }
    
    let url: URL?
    
    func save() throws {
        if let aUrl = url {
            let jsonData = try! JSONSerialization.data(withJSONObject: _dataStore.toJson(), options: [])
            try jsonData.write(to: aUrl)
            print("saved url completer data to \(aUrl)")
        }
    }
    
    // MARK: API
    @objc func recordPageLoad(url: URL) {
        let normalizedUrl = url.normalized
        let wasDirectlyTyped = (normalizedUrl == _lastDirectlyTypedURL)
        _dataStore.performAsyncWithLock {
            if wasDirectlyTyped {
                self._dataStore.addScoreForPage(url: normalizedUrl, score: 10)
            }
            self._dataStore.addScoreForPage(url: url.hostRoot, score: 10)
        }
    }
    
    @objc func recordTitle(_ title: String, forURL: URL) {
        let normalizedUrl = forURL.normalized
        _dataStore.performAsyncWithLock {
            self._dataStore.addTitleForPage(url: normalizedUrl, title: title)
        }
    }
    
    private var _lastDirectlyTypedURL: URL?
    func recordDirectlyTypedURL(url: URL) {
        _lastDirectlyTypedURL = url.normalized
    }
    
    func recordTabExpired(url: URL, title: String) {
        _dataStore.performAsyncWithLock {
            let normalized = url.normalized
            self._dataStore.addScoreForPage(url: normalized, score: 10)
            self._dataStore.addTitleForPage(url: normalized, title: title)
        }
    }
    
    func search(query: String, callback: @escaping([Autocompletion]) -> ()) {
        _dataStore.performAsyncWithLock {
            let entries = self._dataStore.search(query: query)
            let completions: [Autocompletion] = entries.map() {
                entry in
                let a = Autocompletion()
                a._title = entry.title ?? ""
                a._url = entry.url
                a._potentialTypingCompletions = entry.potentialTypingCompletions()
                return a
            }
            DispatchQueue.main.async {
                callback(completions)
            }
        }
    }
    
    // MARK: Private storage functions
    
}


