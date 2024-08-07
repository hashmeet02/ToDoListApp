//****************************************
//         BY-     HASHMEET S. SAINI
//         DATE-   JULY 28TH
// This code has been writte by Hashmeet
//              S. Saini
//****************************************

import UIKit

//This is the controller for the add/edit reminder page.
class addReminderViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!          //Outlet for the name field
    @IBOutlet weak var descriptionField: UITextField!   //Outlet for descritpion field
    @IBOutlet weak var DatePickerView: UIDatePicker!    //Outlet for date picker
    @IBOutlet weak var submitButton: UIButton!          //Outlet for submit button
    @IBOutlet weak var completedStack: UIStackView!     //Outlet for completed switch stack view
    @IBOutlet weak var completedSwitch: UISwitch!       //Outlet for completed switch
    @IBOutlet weak var reminderImageView: UIImageView!  //Outlet for image view.
    
    var remindersList: Reminders!   //Reminders List
    var isEditMode: Bool = false    //Flag to check if this is is editing mode.
    var reminderToEdit: Reminder?   //Var that stores the reminder
    
    //Function triggered when view is loadded
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    //this mode checks if editing mode is on, if it is then it populates fields with
    //details of reminder being edited otherwise hides non-required eleements
    private func configureView() {
        if isEditMode, let reminder = reminderToEdit {
            nameField.text = reminder.name
            descriptionField.text = reminder.description
            DatePickerView.date = reminder.due
            completedStack.isHidden = false
            completedSwitch.setOn(reminder.completed, animated: true)
            if let image = reminder.image{
                reminderImageView.image = UIImage(data: image)
            }
            self.title = "Edit Reminder"
            submitButton.setTitle("Edit Reminder", for: .normal)
        } else {
            completedStack.isHidden = true
        }
    }
    
    //This action is triggered when the share button is pressed. It creates a list
    // of textual and image information to be shared.
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        // Prepare the items to share
        var itemsToShare: [Any] = []
        
        if let name = nameField.text, !name.isEmpty {
            itemsToShare.append(name)
        }
        
        if let description = descriptionField.text, !description.isEmpty {
            itemsToShare.append(description)
        }
        
        if let image = reminderImageView.image {
            itemsToShare.append(image)
        }
        
        // Ensure there is something to share
        guard !itemsToShare.isEmpty else {
            displayErrorAlert(message: "There is nothing to share.")
            return
        }
        
        // Create a UIActivityViewController
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        // Exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .saveToCameraRoll]
        
        // Present the activity view controller
        present(activityViewController, animated: true, completion: nil)
    }
    
    //This action is triggered when submit button is pressed. It validates the 
    // entered information. If edit mode is on then the existing reminder is 
    // updated otherwise a new reminder is created.
    @IBAction func AddReminderBtnPressed(_ sender: UIButton) {
        // Validate the input data
        guard let name = nameField.text, !name.isEmpty,
              let description = descriptionField.text, !description.isEmpty else {
            displayErrorAlert(message: "Please enter a valid name and description.")
            return
        }
        
        // Get the due date from the date picker
        let dueDate = DatePickerView.date
        let image = reminderImageView.image?.jpegData(compressionQuality: 0.8)

        
        if isEditMode {
            // Update the existing reminder using the update method
            reminderToEdit?.update(name: name, description: description,image: image, due: dueDate, completed: completedSwitch.isOn)
            remindersList.saveReminders()
        } else {
            // Create a new reminder
            let newReminder = Reminder(name: name, description: description, image: image, due: dueDate)
            
            // Add the new reminder to the reminders list
            remindersList.addReminder(newReminder)
        }
        
        // Dismiss the view and refresh the previous table view
        navigationController?.popViewController(animated: true)
    }
    
    // Helper function to display an error alert
    private func displayErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //action that is triggered when camera button is clicked, It triggers display
    //of alertController providing suer with the ability to choose between camera
    //or photo library options
    @IBAction func cameraButtonClicked(_ sender: Any) {
        let imagePicker=UIImagePickerController()
        imagePicker.delegate=self
        let alertController=UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if
            UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraAction=UIAlertAction(title: "Camera", style: .default){
                action in imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true)
            }
            alertController.addAction(cameraAction)
        }
        if
            UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let photosAction = UIAlertAction(title: "Photos", style: .default ){
                action in imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true)
            }
            alertController.addAction(photosAction)
        }
        present(alertController, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

//extension for imagagePicker view
extension addReminderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image=info[.originalImage] as? UIImage else{return}
        reminderImageView.image=image
    }
}
