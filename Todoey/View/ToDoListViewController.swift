import UIKit

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
//    let defaults = UserDefaults.standard
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        setting naivgation bar color, using this because there is a bug in the GUI - only seen when running app
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        
//        Creating data persistence using the following linking to users sandbox files - this is how to store more data on an application
        
        loadData()
        
//        Where data is held on user device
//        print(dataFilePath)
        
        
//        Should only use defaults for small amounts of data - bc they must be loaded when the application is opening, only standard types are accepted.
//        if let items = defaults.array(forKey: "ToDoListArray") as? [Item]{
//            itemArray = items
//        }
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
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.name
        
        //        Ternary Operator ==> value = condition ? value if true : value if false
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        print("cell for row at func ran")
        
        return cell
    }
    
    //MARK: - Table View Delegate Method
    
    //    When click then fire
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        self.saveData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //            What will happen when the user clicks on the action
            
            var newItem = Item()
            
            newItem.name = textField.text!
            
            self.itemArray.append(newItem)
            
            self.saveData()
            
//            self.defaults.set(self.itemArray, forKey: "ToDoListArray")
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create an item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveData() {
        
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("error encoding: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadData() {
        
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray  = try decoder.decode([Item].self, from: data)
            } catch {
                print("items decoding failed: \(error)")
            }
        }
    }
}
