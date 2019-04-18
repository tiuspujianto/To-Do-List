//
//  TaskListTableViewController.swift
//  To-Do List
//
//  Created by Timotius Pujianto on 11/4/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Foundation

class TaskListTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {

    
    // Start of variables declaration
    let TASK_SECTION = 1
    let COUNT_SECTION = 0
    let COUNT_CELL = "countTaskCell"
    let CELL_TASK = "taskCell"
    

    @IBAction func markCompletedClick(_ sender: UIButton) {
        let index = sender.tag
        let task = filteredTaskList[index]
        let _ = databaseController?.updateTask(task: task, newTitle: task.taskTitle!, newDescription: task.taskDescription!, newDate: task.taskDueDate! as Date, newStatus: "Completed")
    }
    
    var taskLists: [Task] = []
    var filteredTaskList: [Task] = []
    var listenerType: ListenerType = ListenerType.inProgress
    
    let dateFormatter = DateFormatter()
    weak var taskDelegate: AddTaskDelegate?
    weak var databaseController: DatabaseProtocol?
    
    var selectedStatus: String = ""
    
    
    @IBOutlet weak var selectionSegmented: UISegmentedControl!
    // End of variables declaration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Tasks"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func updateSearchResults(for searchController: UISearchController){
        if let searchText = searchController.searchBar.text?.lowercased(), searchText.count > 0 {
            filteredTaskList = taskLists.filter({(task: Task) -> Bool in return task.taskTitle!.lowercased().contains(searchText)})
        }
        else{
            filteredTaskList = taskLists
        }
        tableView.reloadData();
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == TASK_SECTION{
            return filteredTaskList.count
        }else{
            return 1
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == TASK_SECTION{
            
            let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_TASK, for: indexPath) as! TaskListTableCellController
            
            let task = filteredTaskList[indexPath.row]
            let today = Date()
            
            // -- To differenciate overdue Task, change the text color to red
            if selectionSegmented.selectedSegmentIndex == 0{
                taskCell.markCompletedLabel.isHidden = false
                if (task.taskDueDate! as Date) < today {
                    taskCell.titleLabel.textColor = .red
                    taskCell.dueDateLabel.textColor = .red
                }else{
                    taskCell.titleLabel.textColor = .black
                    taskCell.dueDateLabel.textColor = .black
                }
            }else{
                taskCell.markCompletedLabel.isHidden = true
                taskCell.titleLabel.textColor = .black
                taskCell.dueDateLabel.textColor = .black
            }
            taskCell.markCompletedLabel.tag = indexPath.row
            taskCell.markCompletedLabel.addTarget(self, action: #selector(markCompletedClick), for: UIControl.Event.touchUpInside)
            
            
            taskCell.titleLabel.text = "\(task.taskTitle!)"
            taskCell.dueDateLabel.text = "\(dateFormatter.string(from: task.taskDueDate! as Date))"
            return taskCell
        }
        
            let countCell = tableView.dequeueReusableCell(withIdentifier: COUNT_CELL, for: indexPath)
            countCell.textLabel?.text = "\(taskLists.count) tasks"
            countCell.selectionStyle = .none
            countCell.textLabel?.textAlignment = .center
            return countCell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == TASK_SECTION{
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == TASK_SECTION{
            databaseController?.deleteTask(task: filteredTaskList[indexPath.row])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let index = self.tableView.indexPathForSelectedRow
        if segue.identifier == "showDetailSegue"{
            let destination = segue.destination as! TaskDetailsViewController
            destination.task = filteredTaskList[(index?.row)!]
            destination.summary = filteredTaskList[(index?.row)!].getSummary()
        }
    }
    
    func onTaskChange(change: DatabaseChange, task: [Task]) {
        taskLists = task
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    @IBAction func selectionSegmentedControl(_ sender: Any) {
        databaseController?.removeListener(listener: self)
        switch selectionSegmented.selectedSegmentIndex {
        case 0:
            listenerType = ListenerType.inProgress
        case 1:
            listenerType = ListenerType.completed
        default:
            break;
        }
        databaseController?.addListener(listener: self)
        self.tableView.reloadData()
    }
    @objc func yourButtonClicked(sender: UIButton){
        let index = sender.tag
        let task = filteredTaskList[index]
        let _ = databaseController?.updateTask(task: task, newTitle: task.taskTitle!, newDescription: task.taskDescription!, newDate: task.taskDueDate! as Date, newStatus: "Completed")
    }
}
