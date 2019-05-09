//
//  NetworkRouter.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 04/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation

public typealias NetworkRouterCompletion = (_ error: String?, _ object: Any?) -> Void

// MARK: - NetworkRouter protocol for Network Call
protocol NetworkRouter: class {
    associatedtype EndPoint: EndPointType
    associatedtype Object: Decodable

    func request(_ route: EndPoint, _ session: URLSession, _ object: Object.Type, completion: @escaping NetworkRouterCompletion)
}
