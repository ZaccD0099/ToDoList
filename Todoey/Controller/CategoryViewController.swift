import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    
        tableView.separatorStyle = .none
        loadCategories()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let currentCategory = categories?[indexPath.row] {
            
            cell.textLabel?.text = currentCategory.title ?? "Add a category to get started..."
            
            if let cellBackgroundColor = UIColor(hexString: currentCategory.hexColor) {
                
                cell.backgroundColor = cellBackgroundColor
                
                cell.textLabel?.textColor = ContrastColorOf(cellBackgroundColor, returnFlat: true)
                
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories(_ category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("error occured saving category data: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    override func deleteModel(at indexPath: IndexPath) {
        if let currentCategory = categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(currentCategory)
                }
            }
            catch {
                print("error updating category \(error)")
            }
        }
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category()
            
            newCategory.title = textField.text!
            
            newCategory.hexColor = UIColor.randomFlat().hexValue()
            
            self.saveCategories(newCategory)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create an item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}
