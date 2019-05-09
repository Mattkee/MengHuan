//
//  WikiAPI.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 04/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation

// MARK: - Currency API from yummly
struct WikiAPI: EndPointType {

    var parameters: Parameters = [("action", "query"), ("format", "json"), ("prop", "extracts|pageimages|description|info"), ("redirects", "1"), ("exintro", "1"), ("explaintext", "1"), ("piprop", "original"), ("inprop", "url")]

    var baseURL: URL {
        return URL(string: "http://fr.wikipedia.org/w")!
    }

    var path: String {
        return "/api.php"
    }

    var httpMethod: HTTPMethod = .get

    var task: HTTPTask {
        return .requestParameters(bodyParameters: nil, urlParameters: parameters)
    }
}
