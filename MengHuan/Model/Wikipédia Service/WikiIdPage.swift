//
//  WikiIdPage.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 15/05/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation

// MARK: - Decodable object
struct WikiIdPage: Decodable {

    let query: Query

    struct Query: Decodable {

        let search: [Search]

        struct Search: Decodable {
            let title: String
            let pageid: Int
        }
    }
}
