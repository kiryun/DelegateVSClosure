//
//  ContentViewModel.swift
//  DelegateVsClosure
//
//  Created by Gihyun Kim on 2020/03/11.
//  Copyright © 2020 wimes. All rights reserved.
//

import Foundation

class ContentViewModel: ObservableObject{
    let apiClient: APIClient = APIClient()
    var apiHandler: APIHandler? = nil
    
    init() {
        self.apiHandler = APIHandler(delegate: self)
    }
}

extension ContentViewModel: APIDelegate{
    //request
    func requestDelegate(){
        print("requestDelegate")
        self.apiHandler?.get()
    }
    
    //response
    func responseDelegate(jsonDict: [String : Any]) {
        print("responseDelegate")
        print(jsonDict)
    }
    
    
    func requestClosure(){
        print("requestClosure")
        let url: URL = URL(string: "\(Config.baseURL)/get")!
        
        apiClient.get(url: url, completionHandler: { data, res, err in
            if err == nil{
                if let d = data {
                    if let jsonString = String(data: d, encoding: .utf8){
                        if let dict = jsonStringToDictionary(jsonString: jsonString){
                            print(dict)
                            //doSomething
                        }
                    }
                }
            }else{
                if let err = err{
                    print(err)
                }
            }
        })
    }
}
