//
//  Thread.swift
//  HDMC
//
//  Created by injungkim on 12/08/2018.
//  Copyright © 2018 injungkim. All rights reserved.
//

import UIKit

protocol UsingThread {
    func asyncThread(using block: @escaping () -> Void)
    func syncThread(using block: @escaping () -> Void)
}

extension UsingThread {
    func asyncThread(using block: @escaping () -> Void) {
        DispatchQueue.global().async {
            block()
        }
    }
    
    func syncThread(using block: @escaping () -> Void) {
        DispatchQueue.global().sync {
            block()
        }
    }
    
    func mainThread(using block: @escaping () -> Void) {
        DispatchQueue.main.async {
            block()
        }
    }
    
    func delayAsyncThread(delay: Int, using block: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(delay), execute: {
            block()
        })
    }
}
