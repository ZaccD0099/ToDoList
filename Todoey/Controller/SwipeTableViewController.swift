import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.deleteModel(at: indexPath)

        }
        
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            self.editModel(at: indexPath)

        }

        // customize the action appearance
        deleteAction.image = UIImage(named: K.iconNames.deleteIcon)
        
        editAction.image = UIImage(named: K.iconNames.moreIcon)

        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func deleteModel(at indexPath : IndexPath) {
//        update cell, override
    }
    
    func editModel(at indexPath : IndexPath) {
//        code to override trigger form and edit
    }
}
