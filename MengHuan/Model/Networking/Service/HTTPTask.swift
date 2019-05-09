//
//  HTTPTask.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 04/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation

// MARK: - Manages some type of request
public enum HTTPTask {
    case request
    case requestParameters(bodyParameters: Parameters?, urlParameters: Parameters?)
}
