//
//  CountdownTimer.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 7/18/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import Foundation

protocol Ticker {
    func Tick(timeLeft:Double)
    func Timeout()
}

class CountdownTimerModel:NSObject{
    var timeLeft:Double
    var timer:NSTimer?
    var delegate:Ticker?
    
    init(initialTime:Double, delegate:Ticker?) {
        timeLeft = initialTime
        self.delegate = delegate
    }
    
    func startCountdown() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tick", userInfo: nil, repeats: true)
    }
    
    func tick() {
        timeLeft -= 1
        self.delegate!.Tick(timeLeft)
        if (timeLeft == 0) {
            self.timer?.invalidate()
            self.delegate!.Timeout()
        }
    }
}
