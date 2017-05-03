//
//  URLNormalization.swift
//  wowser
//
//  Created by Nate Parrott on 5/3/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation

extension URL {
    var hostRoot: URL {
        get {
            var comps = URLComponents(url: normalized, resolvingAgainstBaseURL: false)!
            comps.path = ""
            return comps.url!
        }
    }
    var isHostRoot: Bool {
        get {
            return normalized == hostRoot
        }
    }
    var normalized: URL {
        get {
            // rules for URL comparison:
            // http://stackoverflow.com/questions/5801580/how-to-compare-two-nsurls-that-are-practically-equivalent-but-have-cosmetic-stri
            var comps = URLComponents(url: self, resolvingAgainstBaseURL: false)!
            comps.scheme = comps.scheme?.lowercased()
            comps.host = comps.host?.lowercased()
            // strip trailing slashes:
            let path = comps.path
            if path != "" {
                let lastCharIdx = path.index(before: path.endIndex)
                let lastChar = path[lastCharIdx]
                let slash: Character = "/"
                if lastChar == slash {
                    comps.path = path.substring(to: lastCharIdx)
                }
            }
            return comps.url!
        }
    }
}
