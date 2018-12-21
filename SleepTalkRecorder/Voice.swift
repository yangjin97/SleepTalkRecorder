//
//  Voice.swift
//  SleepTalkRecorder
//
//  Created by Yang Jin on 12/20/18.
//  Copyright © 2018 Yang Jin. All rights reserved.
//

import Foundation

class Voice {
    var name: String
    var url: URL
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}
