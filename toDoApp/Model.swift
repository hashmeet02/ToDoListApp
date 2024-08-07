//****************************************
//         BY-     HASHMEET S. SAINI
//         DATE-   JULY 28TH
// This code has been writte by Hashmeet
//              S. Saini
//****************************************

import Foundation

//Remidnder class that describes the information a reminder would hold
//It is made codeable so it can suppurt ondevice storage.
class Reminder: Codable {
    var name: String                //name/title of reminder
    var description: String         //description of title
    var image: Data?                //image of reminder stored as data
    var due: Date                   //dueDate of reminder
    var completed: Bool = false     //completed bool of reminder

    //initializer that has image as optional because adding image is
    //mandatory and doesn't need completed because a user can't mark a
    //reminder as completed during creation.
    init(name: String, description: String, image: Data?, due: Date) {
        self.name = name
        self.description = description
        self.image = image
        self.due = due
    }

    //This is the update method that can take all properties of the reminer optionally and can update whatever information needs
    func update(name: String? = nil, description: String? = nil, image: Data? = nil, due: Date? = nil, completed: Bool? = false) {
        if let name = name {
            self.name = name
        }
        if let description = description {
            self.description = description
        }
        if let image = image {
            self.image = image
        }
        if let due = due {
            self.due = due
        }
        if let completed = completed {
            self.completed = completed
        }
    }

    func formattedDueDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: due)
    }
    
    func daysUntilDue() -> Int? {
        let currentCalendar = Calendar.current
        let now = Date()
        guard let days = currentCalendar.dateComponents([.day], from: now, to: due).day else { return nil }
        return days
    }
}

class Reminders {
    private var reminders: [Reminder]
    
    // Use a static date formatter to avoid creating multiple instances
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    //initilaiser for the class
    init(reminders: [Reminder] = []) {
        self.reminders = reminders
    }

    //Function to add reminder
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        saveReminders()
    }

    //Function to remover reminder
    func removeReminder(at index: Int) {
        guard index >= 0 && index < reminders.count else {
            print("Index out of range")
            return
        }
        reminders.remove(at: index)
        saveReminders()
    }

    //Function to get reminder by index.
    func getReminder(at index: Int) -> Reminder? {
        guard index >= 0 && index < reminders.count else {
            print("Index out of range")
            return nil
        }
        return reminders[index]
    }

    //Functoin to get a sorted list of all reminders
    func allReminders() -> [Reminder] {
        sortRemindersByDueDate()
        return reminders
    }

    //Function to sort a list of reminders
    func sortRemindersByDueDate() {
        reminders.sort { $0.due < $1.due }
    }

    // Save reminders to a plist file using PropertyListEncoder
    func saveReminders() {
        let fileURL = getDocumentsDirectory().appendingPathComponent("reminders.plist")
        do {
            let data = try PropertyListEncoder().encode(reminders)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save reminders: \(error.localizedDescription)")
        }
    }

    // Load reminders from a plist file using PropertyListDecoder
    func loadReminders() {
        let fileURL = getDocumentsDirectory().appendingPathComponent("reminders.plist")
        do {
            let data = try Data(contentsOf: fileURL)
            reminders = try PropertyListDecoder().decode([Reminder].self, from: data)
        } catch {
            print("Failed to load reminders: \(error.localizedDescription)")
        }
    }

    // Helper function to get the documents directory
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
