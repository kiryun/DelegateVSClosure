//
//  APIHandler.swift
//  DelegateVsClosure
//
//  Created by Gihyun Kim on 2020/03/11.
//  Copyright © 2020 wimes. All rights reserved.
//

//using Delegate Pattern
import Foundation

protocol APIDelegate {
    func responseDelegate(jsonDict: [String: Any])
}

class APIHandler{
    var delegate: APIDelegate?
    let session: URLSession = URLSession.shared
    
    init(delegate: APIDelegate) {
        self.delegate = delegate
    }
    
    //GET
    // usisng APIClient
//    func get(){
//        print("APIHandler.get()")
//        let apiClient = APIClient()
//        let url: URL = URL(string: "\(Config.baseURL)/get")!
//
//        apiClient.get(url: url) { data, res, err in
//            if err == nil{
//                if let d = data {
//                    if let jsonString = String(data: d, encoding: .utf8){
//                        if let dict = jsonStringToDictionary(jsonString: jsonString){
////                            print(dict)
//                            //doSomething
//                            self.requestDelegate(jsonDict: dict)
//                        }
//                    }
//                }
//            }else{
//                if let err = err{
//                    print(err)
//                }
//            }
//        }
//    }
    
    //GET
    // non APIClient
    func get(){
        print("APIHandler.get()")
        let url: URL = URL(string: "\(Config.baseURL)/get")!
        var request: URLRequest = URLRequest(url: url)

        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = self.session.dataTask(with: request){ data, res, err in
            if err == nil{
                if let d = data {
                    if let jsonString = String(data: d, encoding: .utf8){
                        if let dict = jsonStringToDictionary(jsonString: jsonString){
//                            print(dict)
                            //doSomething
                            self.requestDelegate(jsonDict: dict)
                        }
                    }
                }
            }else{
                if let err = err{
                    print(err)
                }
            }
        }

        task.resume()
    }
    
    func requestDelegate(jsonDict: [String: Any]){
        self.delegate?.responseDelegate(jsonDict: jsonDict)
    }
}
