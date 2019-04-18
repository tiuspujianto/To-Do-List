//
//  AddTaskDelegate.swift
//  To-Do List
//
//  Created by Timotius Pujianto on 11/4/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import Foundation

protocol AddTaskDelegate: AnyObject {
    func addTask(newTask: Task)-> Bool
}
