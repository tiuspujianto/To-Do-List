//
//  CoreDataController.swift
//  To-Do List
//
//  Created by Timotius Pujianto on 15/4/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {


    let DEFAULT_TASKLIST_NAME = "My List"
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    var taskFetchedResultsController: NSFetchedResultsController<Task>?
    var completedTaskFetchedResultsController: NSFetchedResultsController<Task>?
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "TaskModel")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError(":Failed to load Core Data stack: \(error)")
            }
        }
        super.init()
    }
    func saveContext() {
        if persistantContainer.viewContext.hasChanges{
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    
    func addTask(title: String, decription: String, dueDate: Date, status: String) -> Task {
        let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: persistantContainer.viewContext) as! Task
        task.taskTitle = title
        task.taskDescription = decription
        task.taskDueDate = dueDate as NSDate
        task.taskStatus = status
        saveContext()
        return task
    }
    
    func deleteTask(task: Task) {
        persistantContainer.viewContext.delete(task)
        saveContext()
    }
    
    func updateTask(task: Task, newTitle: String, newDescription: String, newDate: Date, newStatus: String) {
        task.taskTitle = newTitle
        task.taskDescription = newDescription
        task.taskDueDate = newDate as NSDate
        task.taskStatus = newStatus
        saveContext()
    }

    func getSummary(task: Task) -> String{
        return task.getSummary()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == ListenerType.inProgress || listener.listenerType == ListenerType.all {
            listener.onTaskChange(change: .update, task: fetchInProgressTask())
        }else if listener.listenerType == ListenerType.completed || listener.listenerType == ListenerType.all {
            listener.onTaskChange(change: .update, task: fetchCompletedTaskList())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // To fetch task with in progress status
    func fetchInProgressTask() -> [Task]{
        if taskFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "taskStatus == %@", "In Progress")
            // To sort the task based on the due date. 
            let nameSortDescriptor = NSSortDescriptor(key: "taskDueDate", ascending: true)
            fetchRequest.sortDescriptors=[nameSortDescriptor]
            taskFetchedResultsController = NSFetchedResultsController<Task>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            taskFetchedResultsController?.delegate = self
            do {
                try taskFetchedResultsController?.performFetch()
            } catch {
                print ("Fetch Request failed: \(error)")
                }
        }
        var tasks = [Task]()
        if taskFetchedResultsController?.fetchedObjects != nil{
            tasks = (taskFetchedResultsController?.fetchedObjects)!
        }
        return tasks
    }
    
    // To fetch task with completed status
    func fetchCompletedTaskList() -> [Task]{
        if completedTaskFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "taskStatus == %@", "Completed")
            // To sort the task based on the due date.
            let nameSortDescriptor = NSSortDescriptor(key: "taskDueDate", ascending: true)
            fetchRequest.sortDescriptors=[nameSortDescriptor]
            completedTaskFetchedResultsController = NSFetchedResultsController<Task>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            completedTaskFetchedResultsController?.delegate = self
            do {
                try completedTaskFetchedResultsController?.performFetch()
            } catch {
                print ("Fetch Request failed: \(error)")
            }
        }
        var tasks = [Task]()
        if completedTaskFetchedResultsController?.fetchedObjects != nil{
            tasks = (completedTaskFetchedResultsController?.fetchedObjects)!
        }
        return tasks
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == taskFetchedResultsController{
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.inProgress || listener.listenerType == ListenerType.all {
                    listener.onTaskChange(change: .update, task: fetchInProgressTask())
                }
            }
        }        else if controller == completedTaskFetchedResultsController{
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.completed || listener.listenerType == ListenerType.all {
                    listener.onTaskChange(change: .update, task: fetchCompletedTaskList())
                }
            }
        }
    }
}

