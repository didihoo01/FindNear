//
//  WebServiceClient.swift
//  Find Near
//
//  Created by Jiahe Kuang on 12/23/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation

typealias StringMap = [String: String]
typealias Params = StringMap
typealias Headers = StringMap
typealias WebServiceResult = [String: Any]
typealias WebServiceCompletion = (WebServiceResult?, Error?) -> Void

protocol WebServiceClient {
    func get(url: URL, with params: Params, headers: Headers, queue: DispatchQueue, completion: @escaping WebServiceCompletion)
}
