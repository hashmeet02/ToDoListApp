//****************************************
//         BY-     HASHMEET S. SAINI
//         DATE-   JULY 28TH
// This code has been writte by Hashmeet
//              S. Saini
//****************************************
import UIKit

//Class that defines custom table cell
class reminderTableViewCell: UITableViewCell {

    //Outlet for image View in table cell
    @IBOutlet weak var reminderImageView: UIImageView!{
        didSet{
            reminderImageView.layer.cornerRadius=reminderImageView.bounds.width/2
            imageView?.clipsToBounds=true
        }
    }
    @IBOutlet weak var reminderNameLbl: UILabel!    //outlet for reminder title label
    @IBOutlet weak var reminderDescLbl: UILabel!    //outlet for description reminder label
    @IBOutlet weak var reminderDueLbl: UILabel!     //outlet for reminder due date label
    
    //define how table cell is created and its animation at creation
    override func awakeFromNib() {
        super.awakeFromNib()        
    }


    //this function sets the information of all the fieslds and labels during creation.
    func config(with reminder: Reminder) {
        if reminder.completed==true{
            reminderNameLbl.textColor = .systemMint
        }else{
            reminderNameLbl.textColor = .link
        }
        reminderNameLbl.text = reminder.name
        reminderDescLbl.text=reminder.description
        reminderDueLbl.text = reminder.formattedDueDate()
        if let image = reminder.image{
            reminderImageView.image = UIImage(data: image)
        }else{
            reminderImageView.image = nil
        }
    }

}
