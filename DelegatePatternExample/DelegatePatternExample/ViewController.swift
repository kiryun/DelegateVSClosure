//
//  ViewController.swift
//  DelegatePatternExample
//
//  Created by Gihyun Kim on 2020/03/09.
//  Copyright © 2020 wimes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var messageBox: MessageBox?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.messageBox = MessageBox(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 200)))
        if let msg = messageBox{
            msg.frame.origin = CGPoint(x: (UIScreen.main.bounds.width - msg.bounds.width) * 0.5,
                                       y: (UIScreen.main.bounds.height - msg.bounds.height) * 0.5)
            
            msg.backgroundColor = .lightGray
            msg.delegate = self
            self.view.addSubview(msg)
        }
    }


}

extension ViewController: MessageBoxDelegate{
    func touchButton() {
        print("touchButton")
    }
}
