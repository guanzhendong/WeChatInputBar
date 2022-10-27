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
            return UIImage(named: "emoji")
        case .keyboardTrigger:
            return UIImage(named: "keyboard")
        case .clickAudio:
            return UIImage(named: "voice")
        case .clickPlus:
            return UIImage(named: "plus")
        }
    }
    
    var hideAttach: Bool {
        switch self {
        case .keyboardTrigger:
            return false
        default:
            return true
        }
    }
}

enum WechatInputBarState: InputBarState {
    
    typealias Event = WechatButtonEvent
    typealias State = WechatInputBarState
    
    case initial
    case input(_ params: KeyboardParameters? = nil)
    case audio
    case emoji
    case plus
    
    var attachNode: UIView {
        switch self {
        case .initial:
            return UIView()
        case .input:
            return UIView()
        case .audio:
            return AudioBoardView()
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
            return 0
        case .input:
            return 0
        case .audio:
            return 50
        case .emoji:
            return 400
        case .plus:
            return 260
        }
    }
    
    var leftEventList: [Event] {
        switch self {
        case .audio:
            return [.keyboardTrigger]
        default:
            return [.clickAudio]
        }
    }
    
    var rightEventList: [Event] {
        switch self {
        case .emoji:
            return [.keyboardTrigger, .clickPlus]
        case .plus:
            return [.clickEmoji, .clickPlus]
        default:
            return [.clickEmoji, .clickPlus]
        }
    }
    
    var showKeyboard: Bool {
        switch self {
        case .input:
            return true
        default:
            return false
        }
    }
    
    func transitionState(event: Event) -> State {
        switch event {
        case .clickEmoji:
            return .emoji
        case .keyboardTrigger:
            return .input()
        case .clickAudio:
            return .audio
        case .clickPlus:
            return .plus
        }
    }
    
    func transitionState(_ keyboardState: SystemKeyboardEvent) -> State {
        switch keyboardState {
        case .willShow(let params):
            return .input(params)
        case .willHide:
            switch self {
            case .input:
                return .initial
            default:
                return self
            }
        }
    }
}

extension WechatInputBarState: Equatable {
    
    static func == (lhs: WechatInputBarState, rhs: WechatInputBarState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.input, .input):
            return true
        case (.audio, .audio):
            return true
        case (.emoji, .emoji):
            return true
        case (.plus, .plus):
            return true
        default:
            return false
        }
    }
}
