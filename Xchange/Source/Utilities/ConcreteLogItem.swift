//
//  File.swift
//  Xchange
//
//  Created by Yehor Sorokin on 2/20/20.
//  Copyright © 2020 Yehor Sorokin. All rights reserved.
//

import Foundation


final class ConcreteLogItem: LogItem, Codable, Hashable {
    
    static func == (lhs: ConcreteLogItem, rhs: ConcreteLogItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    var dateEstablished: Date
    var description: String
    var status: ConnectionStatus
    

    public enum Keys: CodingKey {
        case date
        case description
        case status
    }
    
    init(date: Date, description: String, status: ConnectionStatus) {
        self.dateEstablished = date
        self.description = description
        self.status = status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ConcreteLogItem.Keys.self)

        dateEstablished = try container.decode(Date.self, forKey: .date)
        description = try container.decode(String.self, forKey: .description)
        status = try container.decode(ConnectionStatus.self, forKey: .status)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ConcreteLogItem.Keys.self)
        try container.encode(dateEstablished, forKey: .date)
        try container.encode(description, forKey: .description)
        try container.encode(status, forKey: .status)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(dateEstablished)
        hasher.combine(description)
        hasher.combine(status)
    }
    
}
