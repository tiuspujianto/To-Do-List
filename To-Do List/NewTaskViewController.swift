//
//  NewTaskViewController.swift
//  To-Do List
//
//  Created by Timotius Pujianto on 11/4/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit

//Function to dismiss keyboard when user touch in blank space
extension UIViewController{
    func hideKeyboard(){
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

class NewTaskViewController: UIViewController,  UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    // Start declaration of variables
    @IBOutlet weak var taskStatusLabel: UITextField!
    @IBOutlet weak var taskTitleLabel: UITextField!
    @IBOutlet weak var taskDescriptionLabel: UITextField!
    @IBOutlet weak var taskDueDateLabel: UITextField!
    
    private var datePicker: UIDatePicker?
    private var statusPicker: UIPickerView?
    let statusList = ["Completed", "In Progress"]
    var selectedStatus: String?
    let dateFormatter = DateFormatter()
    
    var task: Task?
    weak var databaseController: DatabaseProtocol?
    var update: Bool? = false
    // End of the variable declaration
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        // To check an update or new task function
        if task != nil {
            // fill the text label with the selected task detail
            taskTitleLabel.text = task!.taskTitle
            taskDescriptionLabel.text = task!.taskDescription
            taskDueDateLabel.text = dateFormatter.string(from: task!.taskDueDate! as Date)
            taskStatusLabel.text = task!.taskStatus
            // Edit the layout to show the update menu
            self.navigationItem.title = "Edit Task"
        }
        
        taskTitleLabel.delegate = self
        taskDescriptionLabel.delegate=self
    
        // to hide the keyboard when user click outside the keyboard area
        self.hideKeyboard()
        
        // Set up the date picker with done and cancel selection
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        let today = Date()
        datePicker?.minimumDate = today
        
        let toolbar = createToolbar()
        
        taskDueDateLabel.inputAccessoryView = toolbar
        taskDueDateLabel.inputView = datePicker
        
        // Set up task status picker view
        let statusPicker = UIPickerView()
        statusPicker.delegate = self
        
        selectedStatus = statusList[0]
        taskStatusLabel.inputAccessoryView = toolbar
        taskStatusLabel.inputView = statusPicker
    }
    
    // When finish updating, update the task details attributes also
    override func viewWillDisappear(_ animated: Bool) {
        let navigationController = self.navigationController!
        let controllers = navigationController.viewControllers.filter( { $0 is TaskDetailsViewController}) as! [TaskDetailsViewController]
        
        if update! {
            // To pass the new summary of the selected task
            let viewController = controllers.first
            viewController?.summary = databaseController?.getSummary(task: task!)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == taskDueDateLabel && textField == taskStatusLabel{
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Create UIToolbar to confirm the selection in UIPicker (date and status picker)
    func createToolbar() -> UIToolbar{
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        return toolbar
    }
    
    // Done button handler on toolbar
    @objc func donePicker(){
        if taskDueDateLabel.isFirstResponder {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            taskDueDateLabel.text = dateFormatter.string(from: (datePicker?.date)!)
            self.view.endEditing(true)
        }
        if taskStatusLabel.isFirstResponder{
            taskStatusLabel.text = selectedStatus
            self.view.endEditing(true)
        }
    }
    
    // Cancel button handler on toolbar
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStatus = statusList[row]
    }
    
    // Function to handle the update or create button
    @IBAction func saveActionClicked(_ sender: Any) {
        let title = taskTitleLabel.text!
        let description = taskDescriptionLabel.text!
        let date = taskDueDateLabel.text!
        let status = taskStatusLabel.text!
        let dueDate = dateFormatter.date(from: date)
        
        if title != "" && description != "" && date != "" && status != ""{
            // Edit the task
            if task != nil {
                let _ = databaseController!.updateTask(task: task!, newTitle: title, newDescription: description, newDate: dueDate!, newStatus: status)
                update = true
                let message = "Successfully update Task"
                displayMessage(title: "Success", message: message)
                
                // Create a new task
            }else if task == nil {
                let _ = databaseController!.addTask(title: title, decription: description, dueDate: dueDate!, status: status)
                update = false
                let message = "Successfully add a new task"
                displayMessage(title: "Success", message: message)
            }
        }
        // Set error messages when there is an empty fields
        var errorMsg = "There are some empty fields: \n"
        
        if taskTitleLabel.text == ""{
            errorMsg += "- Task Title\n"
        }
        if taskDescriptionLabel.text == ""{
            errorMsg += "- Task Description\n"
        }
        if taskDueDateLabel.text == "" {
            errorMsg += "- Task Due Date\n"
        }
        if taskStatusLabel.text == ""{
            errorMsg += "- Task Status\n"
        }
        
        errorMsg += "Please make sure the fields above are filled first"
        displayMessage(title: "Error", message: errorMsg)
    }
    
    func displayMessage(title: String, message: String){
        //Show a pop up alert message to the user
        //That all fields are not filled.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        if title == "Error"{
            alertController.addAction(UIAlertAction(title: "dismiss", style: UIAlertAction.Style.default, handler: nil))
            
        }else{
            alertController.addAction(UIAlertAction(title: "dismiss", style: UIAlertAction.Style.default, handler: {action in
                self.dismissButtonHandler()
            
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    //When user finish editing and succesfully saved, then click the "dismiss" button from alert controller
    // .. will navigate to the previous view controller.
    func dismissButtonHandler(){
        navigationController?.popViewController(animated: true)
    }

}
