//
//  LogItem.swift
//  Xchange
//
//  Created by Yehor Sorokin on 2/26/20.
//  Copyright © 2020 Yehor Sorokin. All rights reserved.
//

import Foundation

public enum ConnectionStatus: String, Codable {
    case active = "active"
    case terminated = "terminated"
}


protocol LogItem: class {
    
    var dateEstablished: Date { get set }
    var description: String { get set }
    var status: ConnectionStatus { get set }
    
}
