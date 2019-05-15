//
//  WikiInfoServiceTestCase.swift
//  MengHuanTests
//
//  Created by Lei et Matthieu on 15/05/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation
import XCTest
@testable import MengHuan

class WikiInfoServiceTestCase: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testGetWikiInfoShouldPostFailedCallbackIfError() {
        // Given
        let wikiInfoService = WikiInfoService(wikiInfoRouter: Router<WikiAPI, WikiInfo>(), wikiIdPageRouter: Router<WikiIdAPI, WikiIdPage>(), wikiInfoSession: URLSessionFake(data: nil, response: nil, error: FakeWikiInfoResponseData.error), wikiIdPageSession: URLSessionFake(data: FakeWikiIdPageResponseData.wikiIdPageCorrectData, response: FakeWikiIdPageResponseData.responseOK, error: nil))
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        wikiInfoService.getWikiInfo("Terre", type: "planet") { (error, wikiInfo) in
            // Then
            XCTAssertNotNil(error)
            XCTAssertNil(wikiInfo)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func testGetWikiInfoShouldPostFailedCallbackIfNoData() {
        // Given
        let wikiInfoService = WikiInfoService(wikiInfoRouter: Router<WikiAPI, WikiInfo>(), wikiIdPageRouter: Router<WikiIdAPI, WikiIdPage>(), wikiInfoSession: URLSessionFake(data: nil, response: FakeWikiInfoResponseData.responseOK, error: nil), wikiIdPageSession: URLSessionFake(data: nil, response: nil, error: nil))
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        wikiInfoService.getWikiInfo("Terre", type: "planet") { (error, wikiInfo) in
            // Then
            XCTAssertNotNil(error)
            XCTAssertNil(wikiInfo)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func testGetWikiInfoShouldPostFailedCallbackIfIncorrectResponse() {
        // Given
        let wikiInfoService = WikiInfoService(wikiInfoRouter: Router<WikiAPI, WikiInfo>(), wikiIdPageRouter: Router<WikiIdAPI, WikiIdPage>(), wikiInfoSession: URLSessionFake(data: FakeWikiInfoResponseData.wikiInfoCorrectData, response: FakeWikiInfoResponseData.responseKO, error: nil), wikiIdPageSession: URLSessionFake(data: nil, response: nil, error: nil))
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        wikiInfoService.getWikiInfo("Terre", type: "planet") { (error, wikiInfo) in
            // Then
            XCTAssertNotNil(error)
            XCTAssertNil(wikiInfo)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func testGetWikiInfoShouldPostFailedCallbackIfIncorrectData() {
        // Given
        let wikiInfoService = WikiInfoService(wikiInfoRouter: Router<WikiAPI, WikiInfo>(), wikiIdPageRouter: Router<WikiIdAPI, WikiIdPage>(), wikiInfoSession: URLSessionFake(data: FakeWikiInfoResponseData.wikiInfoIncorrectData, response: FakeWikiInfoResponseData.responseOK, error: nil), wikiIdPageSession: URLSessionFake(data: nil, response: nil, error: nil))
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        wikiInfoService.getWikiInfo("Terre", type: "planet") { (error, wikiInfo) in
            // Then
            XCTAssertNotNil(error)
            XCTAssertNil(wikiInfo)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func testGetWikiInfoShouldPostSuccessCallbackIfNoErrorAndCorrectData() {
        // Given
        let wikiInfoService = WikiInfoService(wikiInfoRouter: Router<WikiAPI, WikiInfo>(), wikiIdPageRouter: Router<WikiIdAPI, WikiIdPage>(), wikiInfoSession: URLSessionFake(data: FakeWikiInfoResponseData.wikiInfoCorrectData, response: FakeWikiInfoResponseData.responseOK, error: nil), wikiIdPageSession: URLSessionFake(data: FakeWikiIdPageResponseData.wikiIdPageCorrectData, response: FakeWikiIdPageResponseData.responseOK, error: nil))
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        wikiInfoService.getWikiInfo("Terre", type: "planet") { (error, wikiInfo) in
            // Then
            XCTAssertNil(error)
            XCTAssertNotNil(wikiInfo)

            let title = "Terre"
            let extract = "La Terre est une planète du Système solaire, la troisième plus proche du Soleil et la cinquième plus grande, tant en taille qu'en masse, de ce système planétaire dont elle est également la plus massive des planètes telluriques."
            let source = "https://upload.wikimedia.org/wikipedia/commons/d/d9/Earth_by_the_EPIC_Team_on_21_April_2018.png"
            let description = "troisième planète du Système solaire, laquelle abrite la vie"
            let fullurl = "https://fr.wikipedia.org/wiki/Terre"

            guard let titleWiki = wikiInfo?.query.idPages[0].title else { return }
            guard let extractWiki = wikiInfo?.query.idPages[0].extract else { return }
            guard let sourceWiki = wikiInfo?.query.idPages[0].original.source else { return }
            guard let descriptionWiki = wikiInfo?.query.idPages[0].description else { return }
            guard let fullurlWiki = wikiInfo?.query.idPages[0].fullurl else { return }

            XCTAssertEqual(title, titleWiki)
            XCTAssertEqual(extract, extractWiki)
            XCTAssertEqual(source, sourceWiki)
            XCTAssertEqual(description, descriptionWiki)
            XCTAssertEqual(fullurl, fullurlWiki)

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func testGetWikiIdPageShouldPostFailedCallbackIfError() {
        // Given
        let wikiInfoService = WikiInfoService(wikiInfoRouter: Router<WikiAPI, WikiInfo>(), wikiIdPageRouter: Router<WikiIdAPI, WikiIdPage>(), wikiInfoSession: URLSessionFake(data: FakeWikiInfoResponseData.wikiInfoCorrectData, response: FakeWikiInfoResponseData.responseOK, error: nil), wikiIdPageSession: URLSessionFake(data: nil, response: nil, error: FakeWikiIdPageResponseData.error))
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        wikiInfoService.getWikiInfo("Terre", type: "planet") { (error, wikiInfo) in
            // Then
            XCTAssertNotNil(error)
            XCTAssertNil(wikiInfo)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func testGetWikiIdPageShouldPostFailedCallbackIfNoData() {
        // Given
        let wikiInfoService = WikiInfoService(wikiInfoRouter: Router<WikiAPI, WikiInfo>(), wikiIdPageRouter: Router<WikiIdAPI, WikiIdPage>(), wikiInfoSession: URLSessionFake(data: FakeWikiInfoResponseData.wikiInfoCorrectData, response: FakeWikiInfoResponseData.responseOK, error: nil), wikiIdPageSession: URLSessionFake(data: nil, response: nil, error: nil))
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        wikiInfoService.getWikiInfo("Terre", type: "planet") { (error, wikiInfo) in
            // Then
            XCTAssertNotNil(error)
            XCTAssertNil(wikiInfo)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func testGetWikiIdPageShouldPostFailedCallbackIfIncorrectResponse() {
        // Given
        let wikiInfoService = WikiInfoService(wikiInfoRouter: Router<WikiAPI, WikiInfo>(), wikiIdPageRouter: Router<WikiIdAPI, WikiIdPage>(), wikiInfoSession: URLSessionFake(data: FakeWikiInfoResponseData.wikiInfoCorrectData, response: FakeWikiInfoResponseData.responseOK, error: nil), wikiIdPageSession: URLSessionFake(data: FakeWikiIdPageResponseData.wikiIdPageCorrectData, response: FakeWikiIdPageResponseData.responseKO, error: nil))
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        wikiInfoService.getWikiInfo("Terre", type: "planet") { (error, wikiInfo) in
            // Then
            XCTAssertNotNil(error)
            XCTAssertNil(wikiInfo)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func testGetWikiIdPageShouldPostFailedCallbackIfIncorrectData() {
        // Given
        let wikiInfoService = WikiInfoService(wikiInfoRouter: Router<WikiAPI, WikiInfo>(), wikiIdPageRouter: Router<WikiIdAPI, WikiIdPage>(), wikiInfoSession: URLSessionFake(data: FakeWikiInfoResponseData.wikiInfoCorrectData, response: FakeWikiInfoResponseData.responseOK, error: nil), wikiIdPageSession: URLSessionFake(data: FakeWikiIdPageResponseData.wikiIdPageIncorrectData, response: FakeWikiIdPageResponseData.responseOK, error: nil))
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        wikiInfoService.getWikiInfo("Terre", type: "planet") { (error, wikiInfo) in
            // Then
            XCTAssertNotNil(error)
            XCTAssertNil(wikiInfo)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func testGivenIfNotPlanet_WhenNothingAddToSearchText_ThenSearchTextNoChange() {
        // Given
        let wikiInfoService = WikiInfoService(wikiInfoRouter: Router<WikiAPI, WikiInfo>(), wikiIdPageRouter: Router<WikiIdAPI, WikiIdPage>(), wikiInfoSession: URLSessionFake(data: FakeWikiInfoResponseData.wikiInfoCorrectData, response: FakeWikiInfoResponseData.responseOK, error: nil), wikiIdPageSession: URLSessionFake(data: FakeWikiIdPageResponseData.wikiIdPageCorrectData, response: FakeWikiIdPageResponseData.responseOK, error: nil))
        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        wikiInfoService.getWikiInfo("Terre", type: "") { (_, _) in
            // Then
            let text = wikiInfoService.prepareSearchText("Terre", type: "")
            XCTAssertEqual(text, "Terre")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
}
