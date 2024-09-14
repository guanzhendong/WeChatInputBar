//
//  InputBarState.swift
//  WechatInputBar
//
//  Created by arthurguan on 2022/7/5.
//  Copyright © 2022 arthurguan. All rights reserved.
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

    var leftEventList: [Event] { get }
    var rightEventList: [Event] { get }
    var showKeyboard: Bool { get }
    var attachHeight: CGFloat { get }
    
    func transitionState(event: Event) -> Self
    func transitionState(_ keyboardState: SystemKeyboardEvent) -> Self
}

enum SystemKeyboardEvent {
    case willShow(_ params: KeyboardParameters? = nil)
    case willHide(_ params: KeyboardParameters? = nil)
}

struct KeyboardParameters {
    var height: CGFloat
}
