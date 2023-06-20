//
//  Task.swift
//  TaskTimer
//
//  Created by Yessimkhan Zhumash on 16.06.2023.
//

import Foundation

struct TaskType{
    let symbolName: String
    let typeName: String
}

struct Task {
    var taskName: String
    var taskDescription: String
    var seconds: Int
    var taskType: TaskType
    
    var timeStamp: Double
}

enum CountdownState {
    case suspended
    case running
    case paused
}
