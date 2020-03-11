//
//  ContentView.swift
//  DelegateVsClosure
//
//  Created by Gihyun Kim on 2020/03/11.
//  Copyright © 2020 wimes. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel = ContentViewModel()
    
    var body: some View {
        List{
            Button(action: self.requestClosure){
                Text("Request Closure")
            }
            Button(action: self.requestDelegate){
                Text("Reqeust Delegate")
            }
            
        }
    }
}

extension ContentView{
    
    func requestClosure(){
        self.viewModel.requestClosure()
    }
    
    func requestDelegate(){
        self.viewModel.requestDelegate()
    }
}
