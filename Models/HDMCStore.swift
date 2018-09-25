//
//  HDMCStore.swift
//  HDMC
//
//  Created by 김인중 on 13/08/2018.
//  Copyright © 2018 injungkim. All rights reserved.
//

import UIKit

private var _HDMCStore: HDMCStore!

class HDMCStore: NSObject {
    var firebaseFCMID: String
    
    class var sharedInstance: HDMCStore! {
        if _HDMCStore == nil {
            _HDMCStore = HDMCStore()
        }
        return _HDMCStore
    }
    
    private override init() {
        firebaseFCMID = ""
    }
}
