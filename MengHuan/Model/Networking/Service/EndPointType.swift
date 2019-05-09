//
//  EndPointType.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 04/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation

// MARK: - API Protocol
protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
}
