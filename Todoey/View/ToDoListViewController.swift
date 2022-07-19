import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
// UIApplication.shared.delegate as! AppDelegate refers to the appdelegate of the running instance of the app, cannot refer to the class because it hasn't been initialized - that is why AppDelegate.persistentContainer.viewContext doesn't work.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting naivgation bar color, using this because there is a bug in the GUI - only seen when running app
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
                                                      
        loadData()

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
        
        cell.accessoryType = item.done ? .checkmark : .none
        

        
        return cell
    }
    
    //MARK: - Table View Delegate Method
    
    //    When click then fire
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//  DELETE when clicked, must remove from context before itemArray, because using item array to pull the correct item from context
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        self.saveData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // What will happen when the user clicks on the action
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            
            newItem.name = textField.text!
            newItem.done = false
            
            self.itemArray.append(newItem)
            
            self.saveData()
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create an item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manipulation Methods
    
//    Save data to CoreData context => container -  WRITE
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("error encoding: \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadData() {
        
//        this requires a specific type as seen below you must declare the type. (READ)
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("error fetching request \(error)")
        }
    }
    
    
}
