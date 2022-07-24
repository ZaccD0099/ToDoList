import UIKit
import RealmSwift
import ChameleonFramework


class ToDoListViewController: SwipeTableViewController {
    
    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let categoryHexColor = self.selectedCategory?.hexColor {
            
            title = selectedCategory!.title
            
            guard let navBar = navigationController?.navigationBar else {fatalError("navigation controller could not be set")}
            
            if let categoryColor = UIColor(hexString: categoryHexColor) {
                navBar.tintColor = ContrastColorOf(categoryColor, returnFlat: true)
                
                searchBar.searchTextField.backgroundColor = FlatWhite()
                
                searchBar.barTintColor = categoryColor

                navBar.scrollEdgeAppearance = customNavBarAppearance(categoryColor)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func customNavBarAppearance(_ mainColor : UIColor) -> UINavigationBarAppearance {
        
        let customNavBarAppearance = UINavigationBarAppearance()
        
        let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
            
        customNavBarAppearance.backgroundColor = mainColor
        
        customNavBarAppearance.titleTextAttributes = [.foregroundColor: ContrastColorOf(mainColor, returnFlat: true)]
        customNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(mainColor, returnFlat: true)]
        
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: ContrastColorOf(mainColor, returnFlat: true)]

        customNavBarAppearance.buttonAppearance = barButtonItemAppearance
        customNavBarAppearance.backButtonAppearance = barButtonItemAppearance

        return customNavBarAppearance
            
        }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //MARK: - Table View Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Configure the cell’s contents.
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.name
            cell.accessoryType = item.done ? .checkmark : .none
            
            let categoryColor = UIColor(hexString: self.selectedCategory!.hexColor)
                
            if let color = categoryColor?.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(todoItems!.count))) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        }
        else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    //MARK: - Table View Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedItem = todoItems?[indexPath.row] {
            
            do {
                try realm.write({
                    selectedItem.done = !selectedItem.done
                })
            }
            catch {
                print("error toggling done property in item: \(error)")
            }
            
            tableView.reloadData()
        }
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // What will happen when the user clicks on the action
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.name = textField.text!
                        newItem.dateCreated = Date()
                        self.realm.add(newItem)
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("error saving items: \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create an item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Model Manipulation Methods
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }

    override func deleteModel(at indexPath: IndexPath) {
        if let currentItem = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(currentItem)
                }
            } catch {
                print("error occured deleting an item: \(error)")
            }
        }
    }
    
    override func editModel(at indexPath: IndexPath) {
        
        var textField = UITextField()
        
        let selectedItem = self.todoItems?[indexPath.row]
        
        let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Submit", style: .default) { action in
            
            if let currentItem = selectedItem {
                do {
                    try self.realm.write {
                        currentItem.name = textField.text ?? ""
                    }
                }
                catch {
                    print("error in alert editting block \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.text = selectedItem?.name
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: false, completion: nil)
    }
}


//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let predicate = "name CONTAINS[cd] %@"
        todoItems = todoItems?.filter(predicate, searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

