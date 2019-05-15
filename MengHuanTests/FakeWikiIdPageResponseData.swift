//
//  FakeWikiIdPageResponseData.swift
//  MengHuanTests
//
//  Created by Lei et Matthieu on 15/05/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation

class FakeWikiIdPageResponseData {
    static let responseOK = HTTPURLResponse(
        url: URL(string: "https://openclassrooms.com")!,
        statusCode: 200, httpVersion: nil, headerFields: [:])!

    static let responseKO = HTTPURLResponse(
        url: URL(string: "https://openclassrooms.com")!,
        statusCode: 500, httpVersion: nil, headerFields: [:])!

    class WikiIdPage: Error {}
    static let error = WikiIdPage()

    static var wikiIdPageCorrectData: Data? {
        let bundle = Bundle(for: FakeWikiIdPageResponseData.self)
        guard let url = bundle.url(forResource: "WikiIdPage", withExtension: "json") else { return nil }
        return try? Data(contentsOf: url)
    }
    static let wikiIdPageIncorrectData = "erreur".data(using: .utf8)!
}
