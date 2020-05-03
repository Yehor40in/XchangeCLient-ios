//
//  Config.swift
//  Xchange
//
//  Created by Yehor Sorokin on 2/20/20.
//  Copyright © 2020 Yehor Sorokin. All rights reserved.
//

import UIKit
import Foundation


// MARK: - Basic UI Settings

internal final class Config {

    static var navBarHeight: CGFloat {
        100
    }
    static var menuWidth: CGFloat {
        300
    }
    static var logCellHeight: CGFloat {
        100
    }
    static var stackHeight: CGFloat {
        200
    }
    static var menuExpandedInsets: UIEdgeInsets {
        UIEdgeInsets(top: 50, left: 20, bottom: 20, right: 20)
    }
    static var menuHiddenInsets: UIEdgeInsets {
        UIEdgeInsets(top: 70, left: 70, bottom: 30, right: 20)
    }
    static var menuLabelFont: UIFont {
        UIFont.boldSystemFont(ofSize: 25)
    }
    static var mainNavigationItemTitle: String = "Control Panel"
    
}


// MARK: - Network Alert Settings

extension Config {
    static var networkAlertEstablishedTitle: String = "Connection Established"
    static var networkAlertEstablishedMessage: String = "You are connected to internet"
    static var networkAlertDisconnectedTitle: String = "Connection Error"
    static var networkAlertDisconnectedMessage: String = "You are not connected to intenet, please, check your Wi-Fi or cellular settings."
    
    static let networkAlertEstablishedColor: UIColor = UIColor.green
    static let networkAlertDisconnectedColor: UIColor = UIColor.red
    static let networkAlertTintColor: UIColor = UIColor.black
    
    static var alertCornerRadius: CGFloat = 15
}


// MARK: - Log Settings

extension Config {
    
    static var defaultLogDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("log.json")
    }
    
    static var serverURLString: String = "ws://127.0.0.1:8080"
    
}
