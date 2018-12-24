//
//  AlamofireClient.swift
//  Find Near
//
//  Created by Jiahe Kuang on 12/23/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
import Alamofire

final class AlamofireClient: WebServiceClient {
    
    // A background session manager allows us to continue the fetching in background incase of backgrounding before the opertion is completed
    fileprivate var backgroundSessionManager: Alamofire.SessionManager?
    
    convenience init(backgroundURLSessionIdentifier: String) {
        self.init()
        backgroundSessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: backgroundURLSessionIdentifier))
    }
    
    func get(url: URL, with params: Params, headers: Headers, queue: DispatchQueue, completion: @escaping (WebServiceResult?, Error?) -> Void) {
        submitRequest(method: .get, url: url, params: params, headers: headers, queue: queue, completion: completion)
    }
    
    fileprivate func submitRequest(method: HTTPMethod, url: URL, params: Params?,
                                   headers: Headers?, queue: DispatchQueue, completion: @escaping WebServiceCompletion) {
        var encoding: ParameterEncoding = JSONEncoding.default
        if method == .get || method == .delete {
            encoding = URLEncoding.default
        }
        Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: headers).responseJSON { (response) in
            queue.async {
                if let result = response.result.value as? WebServiceResult {
                    completion(result, nil)
                }
                else {
                    completion(nil, response.result.error)
                }
            }
        }
    }

}
