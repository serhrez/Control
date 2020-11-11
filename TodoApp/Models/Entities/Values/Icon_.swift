//
//  Icon.swift
//  Todo
//
//  Created by sergey on 13.09.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation


enum Icon: Codable {
    case text(String)
    case image(url: String)
    case assetImage(name: String, tintHex: String?)
    
    enum CodingKeys: String, CodingKey {
        case text = "twtw"
        case imageUrlPath
        case assetImageName
        case tintHex
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let text = try? values.decodeIfPresent(String.self, forKey: .text) {
            self = .text(text)
        } else
        if let imageUrl = try? values.decodeIfPresent(String.self, forKey: .imageUrlPath) {
            self = .image(url: imageUrl)
        } else {
            let assetImage = try values.decode(String.self, forKey: .assetImageName)
            let tintHex = try? values.decodeIfPresent(String.self, forKey: .tintHex)
            self = .assetImage(name: assetImage, tintHex: tintHex)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .assetImage(name: name, tintHex: tintHex):
            try container.encode(name, forKey: .assetImageName)
            try container.encodeIfPresent(tintHex, forKey: .tintHex)
        case let .image(url):
            try container.encode(url, forKey: .imageUrlPath)
        case let .text(text):
            try container.encode(text, forKey: .text)
        }
    }
}
