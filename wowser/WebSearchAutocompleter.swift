//
//  WebSearchAutocompleter.swift
//  wowser
//
//  Created by Nate Parrott on 5/4/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation

func LoadSearchAutocompletes(query: String, callback: @escaping ([String]?) -> ()) {
    let baseUrl = URL(string: "https://suggestqueries.google.com/complete/search")!
    var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)!
    urlComponents.queryItems = [URLQueryItem(name: "client", value: "Firefox"), URLQueryItem(name: "q", value: query)]
    let task = URLSession.shared.dataTask(with: urlComponents.url!) { (dataOpt, _, _) in
        if let data = dataOpt,
            let json = try? JSONSerialization.jsonObject(with: data, options: []), let jsonArray = json as? [Any],
                jsonArray.count >= 1,
            let completions = jsonArray[1] as? [String] {
            callback(completions)
        } else {
            callback(nil)
        }
    }
    task.resume()
}

/*
 function loadAutocompletes(query, callback) {
 if (query === "") {
 callback([]);
 } else {
 var url = "https://suggestqueries.google.com/complete/search?client=Firefox&q=" + encodeURIComponent(query);
 xhr(url, function(response) {
 var completions = response ? JSON.parse(response)[1] : [];
 callback(completions);
 });
 }
	}
	
 */
