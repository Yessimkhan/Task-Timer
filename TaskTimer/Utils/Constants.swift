//
//  Constants.swift
//  TaskTimer
//
//  Created by Yessimkhan Zhumash on 16.06.2023.
//

import UIKit

struct Constants{
    //MARK: - variables
    static var hasTopNotch: Bool{
        guard #available(iOS 11, *), let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else{ return false}
        return window.safeAreaInsets.top >= 44
    }
}
