//
//  InputBarState.swift
//  WechatInputBar
//
//  Created by arthurguan on 2022/7/5.
//

import Foundation
import UIKit


protocol InputBarEvent {
    var id: String { get }
    var image: UIImage? { get }
}

protocol InputBarState {
    associatedtype Event: InputBarEvent
    associatedtype State: InputBarState
    var attachNode: UIView { get }
    var attachNodeHeight: CGFloat { get }
    var leftEventList: [Event] { get }
    var rightEventList: [Event] { get }
    var showKeyboard: Bool { get }
    
    func transitionState(event: Event) -> Self
    func transitionState(keyboardState: SystemKeyboardEvent) -> Self
//    func isEqual(_ other: Self) -> Bool
}

enum SystemKeyboardEvent {
    case willShow(params: KeyboardParameters)
    case willHide(params: KeyboardParameters)
}

struct KeyboardParameters {
    var height: CGFloat
}
