//
//  AudioBoardView.swift
//  WechatInputBar
//
//  Created by arthurguan on 2022/7/11.
//  Copyright © 2022 arthurguan. All rights reserved.
//

import UIKit

class AudioBoardView: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        setTitle("按住 说话", for: .normal)
        setTitle("松开 结束", for: .highlighted)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .init(white: 0.9, alpha: 1) : .white
        }
    }
}
