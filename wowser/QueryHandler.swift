//
//  QueryHandler.swift
//  wowser
//
//  Created by Nate Parrott on 5/4/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation

public class QueryHandler<Query: Equatable, Result> {
    public typealias ResultsCallback = ([Result]) -> ()
    public typealias QueryFunction = (Query, @escaping ResultsCallback) -> ()
    public typealias ReuseExistingResultsFunction = ([Result], Query) -> [Result]
    
    public init(queryFn: @escaping QueryFunction, resultsCallback: @escaping ResultsCallback) {
        self.queryFn = queryFn
        self.resultsCallback = resultsCallback
    }
    
    public var reuseExistingResultsFunction: ReuseExistingResultsFunction?
    
    private var results: [Result]? {
        didSet {
            if let r = results {
                resultsCallback(r)
            }
        }
    }
    
    private let queryFn: QueryFunction
    private let resultsCallback: ResultsCallback
    
    public var query: Query? {
        didSet {
            results = results != nil ? tryReusingExistingResults(results: results!) : nil
            if !queryInProgress {
                doQuery()
            }
        }
    }
    
    private func doQuery() {
        queryInProgress = true
        
        let queryAtRequestTime = query
        
        let gotResults = {
            (results: [Result]) in
            // do callback:
            if queryAtRequestTime == self.query {
                self.results = results
            } else if self.results == nil {
                self.results = self.tryReusingExistingResults(results: results)
            }
            self.queryInProgress = false
            if queryAtRequestTime != self.query {
                self.doQuery()
            }
        }
        
        if let q = query {
            queryFn(q, gotResults)
        } else {
            gotResults([])
        }
    }
    
    private var queryInProgress = false
    
    private func tryReusingExistingResults(results: [Result]) -> [Result]? {
        if let fn = reuseExistingResultsFunction, let q = query {
            return fn(results, q)
        } else {
            return nil
        }
    }
}
