//
//  TaskListTableCellController.swift
//  To-Do List
//
//  Created by Timotius Pujianto on 11/4/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit

class TaskListTableCellController: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var markCompletedLabel: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
