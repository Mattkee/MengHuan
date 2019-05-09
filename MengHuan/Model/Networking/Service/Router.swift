//
//  Router.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 04/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation
// this class will handle network calls.
class Router<EndPoint: EndPointType, Object: Decodable>: NetworkRouter {
    private var task: URLSessionTask?
    let networkManager = NetworkManager()

    // MARK: - Network call and returning callback
    func request(_ route: EndPoint, _ session: URLSession, _ object: Object.Type, completion: @escaping NetworkRouterCompletion) {
//        DispatchQueue.main.async {
            do {
                let request = try self.buildRequest(from: route)
                self.task = session.dataTask(with: request) { (data, response, error) in
                    guard error == nil else {
                        print("Please check your network connection.")
                        completion(CustomerDisplayError.network.rawValue, nil)
                        return
                    }
                    self.responseManagement(data, response, object) { (error, object) in
                        completion(error, object)
                    }
                }
            } catch {
                completion(CustomerDisplayError.update.rawValue, nil)
            }
            self.task?.resume()
//        }
    }

    func cancel() {
        self.task?.cancel()
    }

    // MARK: - Building the URL Request.
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {

        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path), cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)

        request.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters, let urlParameters):
                try self.configureParameters(bodyParameters: bodyParameters, urlParameters: urlParameters, request: &request)
            }
            return request
        } catch {
            throw error
        }
    }

    // MARK: Adding Paramaters to request
    fileprivate func configureParameters(bodyParameters: Parameters?, urlParameters: Parameters?, request: inout URLRequest) throws {
        do {
            if let bodyParameters = bodyParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
            if let urlParameters = urlParameters {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }

    // MARK: - Manages received Response.
    fileprivate func responseManagement(_ data: Data?, _ response: URLResponse?, _ object: Object.Type, completion: @escaping NetworkRouterCompletion) {

        guard let response = response as? HTTPURLResponse else {
            print("Please check your API documentation")
            completion(CustomerDisplayError.update.rawValue, nil)
            return
        }
        let result = self.networkManager.handleNetworkResponse(response)
        switch result {
        case .success :
            dataManagement(data, object) { (error, object) in
                completion(error, object)
            }
        case . failure(let networkFailureError) :
            print(networkFailureError)
            completion(CustomerDisplayError.update.rawValue, nil)
            return
        }
    }

    // MARK: - Manages received Data.
    fileprivate func dataManagement(_ data: Data?, _ object: Object.Type, completion: @escaping NetworkRouterCompletion) {
        guard let responseData = data else {
            print(NetworkResponse.noData.rawValue)
            completion(CustomerDisplayError.update.rawValue, nil)
            return
        }
        guard let object = try? JSONDecoder().decode(object.self, from: responseData) else {
            print(NetworkResponse.unableToDecode.rawValue)
            completion(CustomerDisplayError.update.rawValue, nil)
            return
        }
        completion(nil, object)
    }
}
