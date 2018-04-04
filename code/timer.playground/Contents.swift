//: Playground - noun: a place where people can play

import UIKit

enum Type {
    case tick
    case dispatch
}

class Timer {
    typealias TimerAction = ()->()
    private var action: TimerAction
    private var index: Int = 0
    
    init(action: @escaping TimerAction) {
        self.action = action
    }
    
    func start(interval: TimeInterval) {
        self.dispatch(type: .tick, interval: interval)
    }
    
    func dispatch(type: Type, interval: TimeInterval) {
        switch type {
        case .tick:
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval, execute: {
                self.dispatch(type: .tick, interval: interval)
            })
            index += 1
            if index == 1 {
                dispatch(type: .dispatch, interval: interval)
            }
        case .dispatch:
            action()
            index -= 1
            if index > 0 {
                dispatch(type: .dispatch, interval: 0)
            }
        }
    }
}


var timer = Timer.init {
    let now = NSDate()
    print(now)
}
timer.start(interval: 1)

func test() {
    
}

test()
