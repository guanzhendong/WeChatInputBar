//
//  WechatInputBarState.swift
//  WechatInputBar
//
//  Created by arthurguan on 2022/7/5.
//

import Foundation
import UIKit

enum WechatButtonEvent {
    case clickEmoji
    case keyboardTrigger
    case clickAudio
    case clickPlus
}

extension WechatButtonEvent: InputBarEvent {
    var id: String {
        switch self {
        case .clickEmoji:
            return "emoji"
        case .keyboardTrigger:
            return "keyboard"
        case .clickAudio:
            return "audio"
        case .clickPlus:
            return "plus"
        }
    }
    var image: UIImage? {
        switch self {
        case .clickEmoji:
            return UIImage(named: "input_state_emoji")
        case .keyboardTrigger:
            return UIImage(named: "input_state_keyboard")
        case .clickAudio:
            return UIImage(named: "input_state_audio")
        case .clickPlus:
            return UIImage(named: "input_state_plus")
        }
    }
}

enum WechatInputBarState: InputBarState {
    
    typealias Event = WechatButtonEvent
    typealias State = WechatInputBarState
    
    case initial(params: KeyboardParameters?)
    case input(params: KeyboardParameters?)
    case audio
    case emoji
    case plus
    
    var attachNode: UIView {
        switch self {
        case .initial:
            let view = UIView()
            return view
        case .input:
            let view = UIView()
            view.backgroundColor = .green
            return view
        case .audio:
            let view = AudioBoardView()
            return view
        case .emoji:
            let view = EmojiBoardView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
            return view
        case .plus:
            let view = PlusBoardView()
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 260)
            return view
        }
    }
    
    var attachNodeHeight: CGFloat {
        switch self {
        case .initial:
            return attachNode.saferAreaInsets.bottom
        case .input(let params):
            if let height = params?.height {
                return height
            }
            return attachNode.saferAreaInsets.bottom
        case .audio:
            return attachNode.saferAreaInsets.bottom
        case .emoji:
            return 300
        case .plus:
            return 300
        }
    }
    
    var leftEventList: [Event] {
        switch self {
        case .input, .initial, .plus:
            return [.clickAudio]
        case .audio:
            return [.keyboardTrigger]
        case .emoji:
            return [.clickAudio]
        }
    }
    
    var rightEventList: [WechatButtonEvent] {
        switch self {
        case .input, .initial:
            return [WechatButtonEvent.clickEmoji, WechatButtonEvent.clickPlus]
        case .audio:
            return [WechatButtonEvent.clickEmoji, WechatButtonEvent.clickPlus]
        case .emoji:
            return [WechatButtonEvent.keyboardTrigger, WechatButtonEvent.clickPlus]
        case .plus:
            return [WechatButtonEvent.clickEmoji, .keyboardTrigger]
        }
    }
    
    var showKeyboard: Bool {
        switch self {
        case .initial:
            return false
        case .input:
            return true
        case .audio:
            return false
        case .emoji:
            return false
        case .plus:
            return false
        }
    }
    
    func transitionState(event: WechatButtonEvent) -> WechatInputBarState {
        switch event {
        case .clickEmoji:
            return .emoji
        case .keyboardTrigger:
            return .input(params: nil)
        case .clickAudio:
            return .audio
        case .clickPlus:
            return .plus
        }
    }
    
    func transitionState(keyboardState: SystemKeyboardEvent) -> WechatInputBarState {
        switch keyboardState {
        case .willShow(let params):
            return .input(params: params)
        case .willHide(let params):
            switch self {
            case .initial:
                return .initial(params: nil)
            case .input:
                return .initial(params: params)
            case .audio:
                return .audio
            case .emoji:
                return .emoji
            case .plus:
                return .plus
            }
        }
    }
    
//    func isEqual(_ other: WechatInputBarState) -> Bool {
//        switch (self, other) {
//        case (.initial(let param1), .initial(let param2)):
//            return param1?.height == param2?.height && param1?.duration == param2?.duration && param1?.curve == param2?.curve
//        case (.input(let param1), .input(let param2)):
//            return param1?.height == param2?.height && param1?.duration == param2?.duration && param1?.curve == param2?.curve
//        case (.audio, .audio):
//            return true
//        case (.emoji, .emoji):
//            return true
//        case (.plus, .plus):
//            return true
//        default:
//            return false
//        }
//    }
}
