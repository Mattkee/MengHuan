//
//  SolarSystemService.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 06/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation

class SolarSystemService {
    // MARK: - Properties
    private var wikiAPI = WikiAPI()
    private var wikiRouter: Router<WikiAPI, WikiInfo>

    private var wikiSession = URLSession(configuration: .default)

    init(wikiRouter: Router<WikiAPI, WikiInfo> = Router<WikiAPI, WikiInfo>(), wikiSession: URLSession = URLSession(configuration: .default)) {
        self.wikiRouter = wikiRouter
        self.wikiSession = wikiSession
    }

    func getWikiInfo(_ pageId: String, callback: @escaping (String?, WikiInfo?) -> Void) {
        wikiAPI.parameters.append(("pageids", pageId))
        wikiRouter.request(wikiAPI, wikiSession, WikiInfo.self) { (error, object) in
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
}
