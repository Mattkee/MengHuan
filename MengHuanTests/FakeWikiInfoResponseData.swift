//
//  FakeWikiInfoResponseData.swift
//  MengHuanTests
//
//  Created by Lei et Matthieu on 15/05/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation

class FakeWikiInfoResponseData {
    static let responseOK = HTTPURLResponse(
        url: URL(string: "https://openclassrooms.com")!,
        statusCode: 200, httpVersion: nil, headerFields: [:])!

    static let responseKO = HTTPURLResponse(
        url: URL(string: "https://openclassrooms.com")!,
        statusCode: 500, httpVersion: nil, headerFields: [:])!

    class WikiInfo: Error {}
    static let error = WikiInfo()

    static var wikiInfoCorrectData: Data? {
        let bundle = Bundle(for: FakeWikiInfoResponseData.self)
        guard let url = bundle.url(forResource: "WikiInfo", withExtension: "json") else { return nil }
        return try? Data(contentsOf: url)
    }
    static let wikiInfoIncorrectData = "erreur".data(using: .utf8)!
}
