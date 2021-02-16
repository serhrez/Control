//
//  Path.swift
//  Todo
//
//  Created by sergey on 11.06.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation

enum DirPathError: Error, LocalizedError {
  case notFound
  case containerNotFound(String)

  var errorDescription: String? {
    switch self {
      case .notFound: return "Resource not found"
      case .containerNotFound(let id): return "Shared container for group \(id) not found"
    }
  }
}

class DirPath {
    static func fileExists(_ url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
        
    }
    static func inLibrary(_ name: String) throws -> URL {
        return try FileManager.default
            .url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(name)
    }
    
    static func inDocuments(_ name: String) throws -> URL {
        return try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(name)
    }
    
    static func inBundle(_ name: String) throws -> URL {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            throw DirPathError.notFound
        }
        return url
    }
    
    static func inSharedContainer(_ name: String) throws -> URL {
        guard let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.sergeyreznichenko.control") else {
                throw DirPathError.containerNotFound("group.com.sergeyreznichenko.control")
        }
        return url.appendingPathComponent(name)
    }
    
    static func documents() throws -> URL {
        return try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
}
