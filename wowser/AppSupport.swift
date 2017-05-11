//
//  AppSupport.swift
//  wowser
//
//  Created by Nate Parrott on 5/10/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation

extension FileManager {
    var appSupportDirectory: URL {
        get {
            let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
            return URL(fileURLWithPath: path).appendingPathComponent(Bundle.main.bundleIdentifier!)
        }
    }
    
    func ensureAppSupportDirectoryExists() {
        if !fileExists(atPath: appSupportDirectory.path) {
            try? createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
