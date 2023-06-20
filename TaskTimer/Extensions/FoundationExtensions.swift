//
//  FoundationExtensions.swift
//  TaskTimer
//
//  Created by Yessimkhan Zhumash on 16.06.2023.
//

import UIKit

import UIKit
extension Int {
    func appendZeroes () -> String {
        if(self < 10) {
            return "0\(self)"
        } else {
            return "\(self)"
        }
    }
}
extension Double {
    func degreeToRadians () -> CGFloat {
        return CGFloat (self * .pi) / 180
    }
}
