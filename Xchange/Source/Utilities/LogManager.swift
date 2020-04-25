//
//  LogProvider.swift
//  Xchange
//
//  Created by Yehor Sorokin on 2/20/20.
//  Copyright © 2020 Yehor Sorokin. All rights reserved.
//

import Foundation


///--------------------------------
/// - TODO:
///
/// 
///
///--------------------------------


final class LogManager: LogManaging {
    
    static var standard: LogManager = LogManager()
    
    internal var logDirectory: URL
    
    var logQueue = DispatchQueue(label: "com.xchange.LogManager.logQueue", qos: .utility)
    
    
    // MARK: - Initialization
    
    init(logDir: URL = Config.defaultLogDirectory) {
        logDirectory = logDir
    }
    
    
    // MARK: - Methods
    
    func getData() -> [LogItem] {
        
        if let data = try? Data(contentsOf: logDirectory) {
            return try! JSONDecoder().decode([ConcreteLogItem].self, from: data)
        }
        return []
        
    }
    
    func updateData(with new: LogItem, at index: Int? = nil) -> Bool {
        if let item = new as? ConcreteLogItem {
            
            if let data = try? Data(contentsOf: logDirectory), var json = try? JSONDecoder().decode([ConcreteLogItem].self, from: data) {
                switch new.status {
                case .active:
                    json.insert(item, at: 0)
                case .terminated:
                    if let index = index { json[index].status = .terminated }
                }
                try? dataRepresentation(of: json)?.write(to: logDirectory)
                return true
            } else {
                try? dataRepresentation(of: [item])?.write(to: logDirectory)
                return true
            }
            
        }
        return false
    }
    
    func deleteRecord(_ item: LogItem) -> Bool {
        
        if let elem = item as? ConcreteLogItem, let data = getData() as? [ConcreteLogItem] {
            let edited = data.filter { $0.hashValue != elem.hashValue }
            try? dataRepresentation(of: edited)?.write(to: logDirectory)
            return true
        }
        return false
        
    }
    
    func dataRepresentation(of item: [ConcreteLogItem]) -> Data? {
        return try? JSONEncoder().encode(item)
    }
    
}
