//
//  Task+CoreDataProperties.swift
//  To-Do List
//
//  Created by Timotius Pujianto on 14/4/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var taskStatus: String?
    @NSManaged public var taskDueDate: NSDate?
    @NSManaged public var taskDescription: String?
    @NSManaged public var taskTitle: String?
    @NSManaged public var relationship: NSSet?
    func getSummary()-> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let message = """
        Task title: \(self.taskTitle!)
        
        Task description: \(self.taskDescription!)
        
        Task due date: \(dateFormatter.string(from: self.taskDueDate! as Date))
        
        Task status: \(self.taskStatus!)
        
        """
        return message
    }

}

// MARK: Generated accessors for relationship
//extension Task {
//
//    @objc(addRelationshipObject:)
//    @NSManaged public func addToRelationship(_ value: TaskList)
//
//    @objc(removeRelationshipObject:)
//    @NSManaged public func removeFromRelationship(_ value: TaskList)
//
//    @objc(addRelationship:)
//    @NSManaged public func addToRelationship(_ values: NSSet)
//
//    @objc(removeRelationship:)
//    @NSManaged public func removeFromRelationship(_ values: NSSet)
//
//}
