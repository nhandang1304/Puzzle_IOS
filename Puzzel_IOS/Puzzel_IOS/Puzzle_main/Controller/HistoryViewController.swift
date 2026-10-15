import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var tableView: UITableView!
    var histories: [NSManagedObject] = []  
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchHistory()
    }
    // Fetch all records from Core Data
    func fetchHistory() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Assignment2")

        do {
            // Save results into the array
            histories = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    // MARK: - UITableView DataSource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }
    // Create each table row (cell)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)

        let history = histories[indexPath.row]
        
        // Extract values from Core Data
        let birdName = history.value(forKey: "birdName") as? String ?? "Unknown"
        let date = history.value(forKey: "completedDate") as? Date ?? Date()
        let timeTaken = history.value(forKey: "timeTaken") as? Double ?? 0
        let attempts = history.value(forKey: "attemptsCount") as? Int ?? 0
        let success = history.value(forKey: "isSuccess") as? Bool ?? false

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: date)

        cell.textLabel?.text = birdName
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        // Detail text (info about time, attempts, guess status.)
        let statusText = success ? "Correct" : "Incorrect"
        cell.detailTextLabel?.text = "Completed: \(dateString), Time: \(Int(timeTaken))s, Attempts: \(attempts), Guess Status: \(statusText)"
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping

        return cell
    }
    private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    @IBAction func deleteHistoryButtonTapped(_ sender: UIButton) {
        deleteAllHistory()
    }
    func deleteAllHistory() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        // Create request to delete everything in "Assignment2"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Assignment2")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            // Reload UI after deleting
            fetchHistory()
            showAlert(title: "Delete history successfully", message: "All records were deleted")
            
        } catch {
            showAlert(title: "Failed delete", message: "Error: \(error)")
        }
    }
}
