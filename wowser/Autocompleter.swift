//
//  Autocompleter.swift
//  wowser
//
//  Created by Nate Parrott on 5/5/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation

class Autocompletion: NSObject, WWAutocompletion {
    var _title = ""
    var _potentialTypingCompletions = [String]()
    var _url: URL?
    
    func title() -> String! {
        return _title
    }
    
    func potentialTypingCompletions() -> [String] {
        return _potentialTypingCompletions
    }
    
    func url() -> URL! {
        return _url
    }
}

class Autocompleter: NSObject {
    init(callback: @escaping (([Autocompletion]) -> ())) {
        // callback may be called multiple times
        self.callback = callback
        
        super.init()
        
        webSearchAutocompletionQueryHandler = QueryHandler<String, String>(queryFn: { (query, callback) in
            LoadSearchAutocompletes(query: query, callback: {
                (completions) in
                callback(completions ?? [])
            })
        }) { [weak self] (results) in
            self?.webAutocompletions = results
        }
        webSearchAutocompletionQueryHandler.reuseExistingResultsFunction = {
            (oldResults, newQuery) in
            let q = newQuery.lowercased()
            return oldResults.filter({ $0.lowercased().hasPrefix(q) })
        }
    }
    
    let callback: ([Autocompletion]) -> ()
    
    var query = "" {
        didSet(old) {
            if old != query {
                webAutocompletions = []
                webSearchAutocompletionQueryHandler.query = query
            }
        }
    }
    
    var webAutocompletions = [String]() {
        didSet {
            _updateResults()
        }
    }
    
    private var webSearchAutocompletionQueryHandler: QueryHandler<String, String>!
    
    func _updateResults() {
        let webResults = webAutocompletions.map { (searchQuery) -> Autocompletion in
            let result = Autocompletion()
            result._title = searchQuery
            result._url = NSURL.searchEngineURL(for: searchQuery)
            result._potentialTypingCompletions = [searchQuery]
            return result
        }
        callback(webResults)
    }
}
