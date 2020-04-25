//
//  LogManaging.swift
//  Xchange
//
//  Created by Yehor Sorokin on 2/26/20.
//  Copyright © 2020 Yehor Sorokin. All rights reserved.
//

import Foundation

protocol LogManaging: class {
    
    var logDirectory: URL { get }
    var logQueue: DispatchQueue { get }
    
    func getData() -> [LogItem]
    func updateData(with new: LogItem, at index: Int?) -> Bool
    func deleteRecord(_ item: LogItem) -> Bool
    
}
