//
//  TaskDetailsViewController.swift
//  To-Do List
//
//  Created by Timotius Pujianto on 13/4/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit

class TaskDetailsViewController: UIViewController, UITextViewDelegate {

    
    var task: Task?
    var summary: String?
    @IBOutlet weak var taskTextView: UITextView!
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Set the UITextView text to the summary of the selected task
    override func viewWillAppear(_ animated: Bool) {
        taskTextView.text = summary!
    }
    
    // Pass the selected task to the editing view controller via segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "editTaskSegue"{
            let destination = segue.destination as! NewTaskViewController
            destination.task = task
        }
    }
}
