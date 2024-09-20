//
//  WechatInputBar.swift
//  WechatInputBar
//
//  Created by arthurguan on 2022/7/5.
//  Copyright © 2022 arthurguan. All rights reserved.
//

import Foundation
import UIKit

protocol WechatInputBarDelegate: AnyObject {
    
    func onStateChanged(_ inputBar: WechatInputBar)
}

class WechatInputBar: InputBarAccessoryView {
    
    // MARK: - Public Properties
    
    public weak var aDelegate: WechatInputBarDelegate?
    
    public var state: WechatInputBarState = .initial {
        didSet {
            if oldValue == state {
                return
            }
            changeBar()
            aDelegate?.onStateChanged(self)
        }
    }
    
    
    
    // MARK: - Private Properties
    
    private lazy var voiceButton: InputBarSendButton = {
        let btn =  InputBarSendButton()
        btn.image = UIImage(named: "voice")
        btn.setSize(CGSize(width: 40, height: 40), animated: false)
        btn.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var emojiButton: InputBarSendButton = {
        let btn =  InputBarSendButton()
        btn.image = UIImage(named: "emoji")
        btn.setSize(CGSize(width: 40, height: 40), animated: false)
        btn.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var plusButton: InputBarSendButton = {
        let btn =  InputBarSendButton()
        btn.image = UIImage(named: "plus")
        btn.setSize(CGSize(width: 40, height: 40), animated: false)
        btn.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var audioBoard: AudioBoardView = {
        let v = AudioBoardView()
        return v
    }()
    
    private lazy var emojiBoard: EmojiBoardView = {
        let v = EmojiBoardView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
        return v
    }()
    
    private lazy var plusBoard: PlusBoardView = {
        let v = PlusBoardView()
        return v
    }()
    
    private var bottomConstraint: NSLayoutConstraint?
    private let keyboardManager = KeyboardManager()
    private let keyboardManager2 = KeyboardManager()
    
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview != nil {
            setupKeyboardManager()
        }
    }
    
    
    
    // MARK: - Override
    
    override func calculateMaxTextViewHeight() -> CGFloat {
        return 100
    }

    
    
    // MARK: - Private
    
    private func configure() {
        backgroundColor = .clear
        backgroundView.backgroundColor = UIColor(hexString: "#F7F7F7")
        
        padding = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        inputTextView.backgroundColor = .white
        inputTextView.placeholder = ""
        inputTextView.returnKeyType = .send
        
        inputTextView.layer.cornerRadius = 5
        inputTextView.layer.masksToBounds = true
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        
        inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 11.5, left: 16, bottom: 11.5, right: 12)
        middleContentViewPadding.right = 3
        
        // 左边
        setLeftStackViewWidthConstant(to: 40, animated: false)
        setStackViewItems([voiceButton], forStack: .left, animated: false)
        
        // 右边
        setRightStackViewWidthConstant(to: 80, animated: false)
        setStackViewItems([emojiButton, plusButton], forStack: .right, animated: false)
        
        
        separatorLine.isHidden = true
        isTranslucent = false
        
        shouldManageSendButtonEnabledState = false
    }
    
    private func setupKeyboardManager() {
        keyboardManager.bind(inputAccessoryView: self)
        bottomConstraint = keyboardManager.constraints?.bottom
        
        keyboardManager2.on(event: .willShow) { [weak self] _ in
            guard let self = self else { return }
            self.state = self.state.transitionState(.willShow())
        }
        
        keyboardManager2.on(event: .willHide) { [weak self] _ in
            guard let self = self else { return }
            self.state = self.state.transitionState(.willHide())
        }
    }
    
    @objc private func handleButtonClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender {
        case voiceButton:
            state = state.transitionState(event: sender.isSelected ? .clickAudio : .keyboardTrigger)
        case emojiButton:
            state = state.transitionState(event: sender.isSelected ? .clickEmoji : .keyboardTrigger)
        case plusButton:
            state = state.transitionState(event: sender.isSelected ? .clickPlus : .keyboardTrigger)
        default:
            break
        }
    }
    
    private func changeBar() {
        guard let superview = superview else { return }
        
        // 是否展示键盘
        if state.showKeyboard {
            if inputTextView.canBecomeFirstResponder {
                inputTextView.becomeFirstResponder()
            }
        } else {
            inputTextView.resignFirstResponder()
        }
        
        // 切换 左右按钮的图标
        voiceButton.image = state.leftEventList.first?.image
        emojiButton.image = state.rightEventList.first?.image
        plusButton.image = state.rightEventList.last?.image
        
        // 切换 左右按钮的选择与否
        voiceButton.isSelected = state == .audio
        emojiButton.isSelected = state == .emoji
        plusButton.isSelected = state == .plus
        
        // 切换 附加视图的显示与否
        audioBoard.isHidden = state != .audio
        emojiBoard.isHidden = state != .emoji
        plusBoard.isHidden = state != .plus
        
        switch state {
        case .initial:
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.bottomConstraint?.constant = 0
                superview.layoutIfNeeded()
            }
            
        case .input:
            break
            
        case .audio:
            if audioBoard.superview == nil {
                inputTextView.addSubview(audioBoard)
                audioBoard.frame = inputTextView.bounds
            }
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.bottomConstraint?.constant = 0
                superview.layoutIfNeeded()
            }
            
        case .emoji:
            if emojiBoard.superview == nil {
                superview.addSubview(emojiBoard)
            }
            emojiBoard.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: state.attachHeight)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.emojiBoard.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.state.attachHeight, width: UIScreen.main.bounds.width, height: self.state.attachHeight)
                self.bottomConstraint?.constant = -self.state.attachHeight
                superview.layoutIfNeeded()
            }
            
        case .plus:
            if plusBoard.superview == nil {
                superview.addSubview(plusBoard)
            }
            plusBoard.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: state.attachHeight)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.plusBoard.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.state.attachHeight, width: UIScreen.main.bounds.width, height: self.state.attachHeight)
                self.bottomConstraint?.constant = -self.state.attachHeight
                superview.layoutIfNeeded()
            }
            
        }
    }
}


