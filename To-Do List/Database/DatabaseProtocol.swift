//
//  DatabaseProtocol.swift
//  To-Do List
//
//  Created by Timotius Pujianto on 14/4/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//
import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

// Listener type used to fetch different result of task
enum ListenerType{
    case inProgress
    case completed
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onTaskChange(change: DatabaseChange, task: [Task])
}

protocol DatabaseProtocol: AnyObject {
    func addTask(title: String, decription: String, dueDate: Date, status: String) -> Task
    func deleteTask(task: Task)
    func updateTask(task: Task, newTitle: String, newDescription: String, newDate: Date, newStatus: String)
    func getSummary(task: Task) -> String
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
