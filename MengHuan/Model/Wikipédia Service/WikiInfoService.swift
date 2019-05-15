//
//  WikiInfoService.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 06/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation

class WikiInfoService {
    // MARK: - Properties
    private var wikiAPI = WikiAPI()
    private var wikiIdAPI = WikiIdAPI()
    private var wikiInfoRouter: Router<WikiAPI, WikiInfo>
    private var wikiIdPageRouter: Router<WikiIdAPI, WikiIdPage>

    private var wikiInfoSession = URLSession(configuration: .default)
    private var wikiIdPageSession = URLSession(configuration: .default)

    init(wikiInfoRouter: Router<WikiAPI, WikiInfo> = Router<WikiAPI, WikiInfo>(), wikiIdPageRouter: Router<WikiIdAPI, WikiIdPage> = Router<WikiIdAPI, WikiIdPage>(), wikiInfoSession: URLSession = URLSession(configuration: .default), wikiIdPageSession: URLSession = URLSession(configuration: .default) ) {
        self.wikiInfoRouter = wikiInfoRouter
        self.wikiIdPageRouter = wikiIdPageRouter
        self.wikiInfoSession = wikiInfoSession
        self.wikiIdPageSession = wikiIdPageSession
    }
}

extension WikiInfoService {
    // MARK: - Calculs
    func prepareSearchText(_ search: String, type: String) -> String {
        if type == "planet" {
            let searchText = search + " Planète"
            return searchText
        } else {
            return search
        }
    }
}

extension WikiInfoService {
    // MARK: - Network Call
    func getWiki(_ pageId: String, callback: @escaping (String?, WikiInfo?) -> Void) {
        wikiAPI.parameters.append(("pageids", pageId))
        wikiInfoRouter.request(wikiAPI, wikiInfoSession, WikiInfo.self) { (error, object) in
            DispatchQueue.main.async {
                guard error == nil else {
                    callback(error, nil)
                    return
                }
                let wikiInfo = object as? WikiInfo
                callback(nil, wikiInfo)
            }
        }
    }
    func getWikiInfo(_ search: String, type: String, callback: @escaping (String?, WikiInfo?) -> Void) {
        let searchText = self.prepareSearchText(search, type: type)
        wikiIdAPI.parameters.append(("srsearch", searchText))
        wikiIdPageRouter.request(wikiIdAPI, wikiIdPageSession, WikiIdPage.self) { (error, object) in
            DispatchQueue.main.async {
                guard error == nil else {
                    callback(error, nil)
                    return
                }
                let wikiIdPage = object as? WikiIdPage
                guard let pageId = wikiIdPage?.query.search[0].pageid else { return }
                let pageIdString = String(pageId)

                self.getWiki(pageIdString) { (error, object) in
                    guard let wikiInfo = object else {
                        callback(error, nil)
                        return
                    }
                    callback(nil, wikiInfo)
                }
            }
        }
    }
}
