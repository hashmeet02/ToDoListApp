//****************************************
//         BY-     HASHMEET S. SAINI
//         DATE-   JULY 28TH
// This code has been writte by Hashmeet
//              S. Saini
//****************************************
import UIKit

//This is view controller for the main page.
class remindersTableViewController: UITableViewController {

    // Instance of Reminders class
    var remindersList = Reminders()                     //Create instance of Reminders Class
    var sectionedReminders: [String: [Reminder]] = [:]  //Dictionary that sores reminders by sections or date
    var sectionTitles: [String] = []                    //List of Section titles
    var editPressed: Bool = false                       //Boolean to check if the editing button is pressed
    @IBOutlet var remindersTableView: UITableView!      //outlet for reminders table view.
    var showCompletedOnly: Bool = false                 // Flag to track if only completed reminders should be shown

    //When view is loaded, the reminders are retrieved from the storage and orgnazed by date
    override func viewDidLoad() {
        super.viewDidLoad()
        remindersList.loadReminders()
        organizeRemindersByDate()
    }
    
    //When view is about to appear, the reminders are orgnaized by date and rable is reloaded.
    override func viewWillAppear(_ animated: Bool) {
        organizeRemindersByDate()
        remindersTableView.reloadData()
    }

    //Funtction triggered when complredRemindersBtn is pressed, when it is toogled, the flag
    // is toggled, images of button is changed, reminders are organized by date and table
    // view is reloaded.
    @IBAction func completedRemindersBtnPressed(_ sender: UIBarButtonItem) {
        showCompletedOnly.toggle()
        
        sender.image = showCompletedOnly ? 
            UIImage(systemName: "checklist.checked")
            :
            UIImage(systemName: "checklist")
        
        organizeRemindersByDate()
        remindersTableView.reloadData()
    }

    //Action triggered when the edit button is pressed, edit flag is toggled, table's
    // editing mode is activated and button's title is changed
    @IBAction func edit(_ sender: UIBarButtonItem) {
        editPressed.toggle()
        
        remindersTableView.setEditing(editPressed, animated: true)
        
        sender.title = editPressed ? "Done" : "Edit"
    }

    
    // MARK: - Table view data source

    //define number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    //define numebr of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = sectionTitles[section]
        return sectionedReminders[sectionTitle]?.count ?? 0
    }

    //create cells for the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! reminderTableViewCell
        
        let sectionTitle = sectionTitles[indexPath.section]
        if let reminder = sectionedReminders[sectionTitle]?[indexPath.row] {
            cell.config(with: reminder)
        }
        return cell
    }

    //Sets the titles for the sections
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sectionTitle = sectionTitles[indexPath.section]
            if let reminder = sectionedReminders[sectionTitle]?[indexPath.row] {
                // Remove the reminder from the reminders list
                remindersList.removeReminder(at: indexPath.row)
                // Remove the reminder from the sectioned reminders
                sectionedReminders[sectionTitle]?.remove(at: indexPath.row)
                
                // If the section is now empty, remove the section
                if sectionedReminders[sectionTitle]?.isEmpty == true {
                    sectionedReminders.removeValue(forKey: sectionTitle)
                    sectionTitles.removeAll { $0 == sectionTitle }
                }
                
                // Reload the table view
                tableView.reloadData()
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return editPressed
    }
    
    // This function defines what needs to be done when a row is moved at from one section to another
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let sectionTitle = sectionTitles[fromIndexPath.section]
        let newSectionTitle = sectionTitles[to.section]
        
        // Get the reminder being moved
        guard let reminder = sectionedReminders[sectionTitle]?[fromIndexPath.row] else { return }
        
        // Remove the reminder from the old section
        sectionedReminders[sectionTitle]?.remove(at: fromIndexPath.row)
        
        // Preserve the original time (hour and minute)
        let originalTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: reminder.due)
        
        // Update the reminder’s date based on the new section
        let calendar = Calendar.current
        let newBaseDate: Date
        switch newSectionTitle {
        case "Today":
            newBaseDate = calendar.startOfDay(for: Date())
        case "Yesterday":
            newBaseDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
        case "Tomorrow":
            newBaseDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
        default:
            newBaseDate = Reminders.dateFormatter.date(from: newSectionTitle) ?? calendar.startOfDay(for: Date())
        }
        
        // Combine the new base date with the original time components
        var newDateComponents = calendar.dateComponents([.year, .month, .day], from: newBaseDate)
        newDateComponents.hour = originalTimeComponents.hour
        newDateComponents.minute = originalTimeComponents.minute
        let newDate = calendar.date(from: newDateComponents) ?? reminder.due
        
        reminder.due = newDate
        
        // Add the reminder to the new section
        if sectionedReminders[newSectionTitle] == nil {
            sectionedReminders[newSectionTitle] = []
        }
        sectionedReminders[newSectionTitle]?.insert(reminder, at: to.row)
        
        // Ensure sections and rows are updated
        organizeRemindersByDate()
        tableView.reloadData()
    }

    //Defines the section title based on the date. the title is changed to today, yesterday or tomorrow or
    // to the date itself.
    func sectionTitle(for date: Date) -> String {
        let today = Calendar.current.startOfDay(for: Date())
        let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        if Calendar.current.isDate(date, inSameDayAs: today) {
            return "Today"
        } else if Calendar.current.isDate(date, inSameDayAs: dayBefore) {
            return "Yesterday"
        } else if Calendar.current.isDate(date, inSameDayAs: tomorrow) {
            return "Tomorrow"
        } else {
            return Reminders.dateFormatter.string(from: date)
        }
    }
    
    //This function organizes reminders between section. It also filters data reminders based on completion
    func organizeRemindersByDate() {
        sectionedReminders.removeAll()
        sectionTitles.removeAll()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // Create a date formatter for section titles
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        Reminders.dateFormatter = dateFormatter
        
        // Dictionary to hold reminders by section name
        var remindersByDate: [Date: [Reminder]] = [:]
        
        for reminder in remindersList.allReminders() {
            // Filter reminders if showing only completed ones
            if showCompletedOnly && !reminder.completed {
                continue
            }
            
            let startOfDay = calendar.startOfDay(for: reminder.due)
            let sectionName = sectionTitle(for: startOfDay)
            
            // Add reminders to the dictionary under the appropriate date
            if remindersByDate[startOfDay] == nil {
                remindersByDate[startOfDay] = []
            }
            remindersByDate[startOfDay]?.append(reminder)
        }
        
        // Sort dates and prepare section titles
        let sortedDates = remindersByDate.keys.sorted()
        for date in sortedDates {
            let sectionName = sectionTitle(for: date)
            sectionTitles.append(sectionName)
            sectionedReminders[sectionName] = remindersByDate[date]
        }
    }
    
    // This function to checks which segue to perform (add Reminder or edit reminder)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? addReminderViewController {
            destinationVC.remindersList = remindersList
            
            if segue.identifier == "editReminderSegue",
               let indexPath = tableView.indexPathForSelectedRow {
                let sectionTitle = sectionTitles[indexPath.section]
                destinationVC.isEditMode = true
                destinationVC.reminderToEdit = sectionedReminders[sectionTitle]?[indexPath.row]
            } else {
                destinationVC.isEditMode = false
            }
        }
    }
}
