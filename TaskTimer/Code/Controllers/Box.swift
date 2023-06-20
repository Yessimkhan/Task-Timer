//
//  BOX.swift
//  TaskTimer
//
//  Created by Yessimkhan Zhumash on 16.06.2023.
//

import Foundation

class Box<T> {
    typealias Listener = (T) -> ()
    
    // MARK: - variables
    
    var value: T {
        didSet{
            listener?(value)
        }
    }
    
    var listener: Listener?
    
    // MARK: - inits
    
    init(_ value: T) {
        self.value = value
    }
    // MARK: - functions
    
    func bind(listener: Listener?){
        self.listener = listener
    }
    
    func removebBinding(){
        self.listener = nil
    }
    
}
