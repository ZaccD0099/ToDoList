import UIKit

class ToDoListViewController: UITableViewController {
    
    var itemArray = [
        "Bannas",
        "Apples",
        "Oranges"
    ]
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        setting naivgation bar color, using this because there is a bug in the GUI
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        if let items = defaults.array(forKey: "ToDoListArray") as? [String] {
            itemArray = items
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: - Table View Datasource Methods

    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // Fetch a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
       
       // Configure the cell’s contents.
        cell.textLabel!.text = itemArray[indexPath.row]
           
       return cell
    }
    
    //MARK: - Table View Delegate Method
    
//    When click then fire
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
//            What will happen when the user clicks on the action
            self.itemArray.append(textField.text!)
            
            self.defaults.set(self.itemArray, forKey: "ToDoListArray")
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create an item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
