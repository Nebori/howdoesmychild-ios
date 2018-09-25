//
//  HDMCStudentInfo.swift
//  HDMC
//
//  Created by 김인중 on 17/09/2018.
//  Copyright © 2018 injungkim. All rights reserved.
//

import UIKit

struct HDMCStudentInfo: Codable {
    // 많은 값이 있지만 변경될 수 있어 사용하는 값만 파싱
    var name: String
    var verify: String
}
