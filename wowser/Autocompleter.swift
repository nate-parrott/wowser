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
        
        // create web search query handler:
        
        let webSearchAutocompletionQueryHandler = QueryHandler<String, Autocompletion>(queryFn: { (query, callback) in
            LoadSearchAutocompletes(query: query, callback: {
                (completionStrings) in
                let completions = completionStrings?.map({ autocompletionWithWebSearchQuery($0) })
                callback(completions ?? [])
            })
        }) { [weak self] (results) in
            self?.resultsByCategory["web"] = results
        }
        
        webSearchAutocompletionQueryHandler.reuseExistingResultsFunction = {
            (oldResults, newQuery) in
            let q = newQuery.lowercased()
            return oldResults.filter({ $0.title().lowercased().hasPrefix(q) })
        }
        
        // create history query handler:
        
        let historyQueryHandler = QueryHandler<String, Autocompletion>(queryFn: { (query, callback) in
            URLCompleter.shared.search(query: query, callback: callback)
        }) { [weak self] (results) in
            self?.resultsByCategory["history"] = results
        }
        
        queryHandlers = [webSearchAutocompletionQueryHandler, historyQueryHandler]
    }
    
    let callback: ([Autocompletion]) -> ()
    
    var query = "" {
        didSet(old) {
            if old != query {
                for handler in queryHandlers { handler.query = query }
            }
        }
    }
    
    private var queryHandlers = [QueryHandler<String, Autocompletion>]()
    private var resultsByCategory = [String: [Autocompletion]]() {
        didSet {
            // assert main queue:
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            
            let categories = ["history", "web"]
            var completions = [Autocompletion]()
            for category in categories {
                if let results = resultsByCategory[category] {
                    completions += results
                }
            }
            
            completions = completions.filter({ $0.title() != "" })
            
            callback(completions)
        }
    }
}

private func autocompletionWithWebSearchQuery(_ searchQuery: String) -> Autocompletion {
    let result = Autocompletion()
    result._title = searchQuery
    result._url = NSURL.searchEngineURL(for: searchQuery)
    result._potentialTypingCompletions = [searchQuery]
    return result
}
