//
//  MessageBox.swift
//  DelegatePatternExample
//
//  Created by Gihyun Kim on 2020/03/09.
//  Copyright © 2020 wimes. All rights reserved.
//

import Foundation
import UIKit

protocol MessageBoxDelegate: class {
    func touchButton()
}

class MessageBox: UIView{
    weak var delegate: MessageBoxDelegate?
    var button: UIButton?
    
    public override init(frame: CGRect){
        super.init(frame: frame)
        
        configure()
    }
    
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
    }
    
    func configure(){
        button = UIButton(type: .system)
        if let btn = button{
            btn.setTitle("SEND", for: .normal)
            btn.sizeToFit()
            btn.frame.origin = CGPoint(x: (self.bounds.width - btn.bounds.width) * 0.5,
                                       y: (self.bounds.height - btn.bounds.height) * 0.5)
            btn.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        }
    }
    
    
    @objc func tapButton(){
        delegate?.touchButton() // 위임한 곳(현재 ViewController)의 touchButton() 메서드 실행
    }
}
