//
//  WikiInfo.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 06/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation

struct WikiInfo: Decodable {

    let query: Query

    struct Query: Decodable {
        var idPages: [IdPage]

        private enum CodingKeys: String, CodingKey {
            case pages
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.idPages = [IdPage]()

            let subContainer = try container.nestedContainer(keyedBy: GenericCodingKeys.self, forKey: .pages)
            for key in subContainer.allKeys {
                let idPage = try subContainer.decode(IdPage.self, forKey: key)

                self.idPages.append(idPage)
            }
        }
    }

    struct IdPage: Decodable {

        var title: String
        var extract: String
        var original: Original
        var description: String?
        var fullurl: String

        private enum CodingKeys: String, CodingKey {
            case title
            case extract
            case original
            case description
            case fullurl
        }

        struct Original: Decodable {
            let source: String
        }
    }
}

struct GenericCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { self.intValue = intValue; self.stringValue = "\(intValue)" }
}
