//
//  EditStockTableViewController.swift
//  MyStocks_Hashmeet
//
//  Created by Hashmeet Saini on 2024-08-04.
//
//****************************************
//         BY-     HASHMEET S. SAINI
//         DATE-   AUGUST-5th
// This code has been writte by Hashmeet
//              S. Saini.
//****************************************

import UIKit

//This is the Edit Table view controller page. 
class EditStockTableViewController: UITableViewController {
    var stock: StockEntity! //variable to store the stock being edited.
    
    //Outlets for table cells.
    @IBOutlet weak var nameRow: UITableViewCell!
    @IBOutlet weak var lowPriceRow: UITableViewCell!
    @IBOutlet weak var highPriceRow: UITableViewCell!
    @IBOutlet weak var lastPriceRow: UITableViewCell!
    @IBOutlet weak var perNetChangeRow: UITableViewCell!
    @IBOutlet weak var temperatureSlider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //function called when view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure initial UI with stock data
        nameRow.textLabel?.text = stock.name
        temperatureSlider.value = temperatureValue(for: stock.temp)
        title=stock.symbol
        nameRow.backgroundColor = UIColor(named: stock.temp ?? "white")
        nameRow.textLabel?.textColor = .black
        
        // Start loading animation
        activityIndicator.startAnimating()
        tableView.isUserInteractionEnabled = false

        // Fetch stock details from API
        fetchStockDetails()
        
        // Initialize the refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    //fucntion called when user refreshes the page.
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Fetch the latest stocks from the API
        fetchStockDetails()
    }
    
    //converting temp String to a int value to use the slider.
    func temperatureValue(for temp: String?) -> Float {
        switch temp {
        case "cold":
            return 0.0
        case "hot":
            return 0.5
        case "veryHot":
            return 1.0
        default:
            return 0.0
        }
    }
    
    //this function fetches the stock details and sets them to the appropriate fields.
    func fetchStockDetails() {
        NetworkManager.shared.fetchStockDetails(performanceId: stock.performanceId!) { [weak self] stockDetails in
            guard let self = self, let stockDetails = stockDetails else {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.refreshControl?.endRefreshing()
                    self?.tableView.isUserInteractionEnabled = true
                }
                return
            }
            
            DispatchQueue.main.async {
                self.lowPriceRow.textLabel?.text = "Low Price: \(stockDetails.lowPrice)"
                self.highPriceRow.textLabel?.text = "High Price: \(stockDetails.highPrice)"
                self.lastPriceRow.textLabel?.text = "Last Price: \(stockDetails.lastPrice)"
                self.perNetChangeRow.textLabel?.text = "Net Change: \(stockDetails.percentNetChange)%"
                
                // Stop loading animation
                self.activityIndicator.stopAnimating()
                self.refreshControl?.endRefreshing()
                self.tableView.isUserInteractionEnabled = true
            }
        }
    }

    //When the save button is tapped, the user's changes to the slider (ranking of stocks) are saved to the
    //core data container.
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let tempValue = temperatureSlider.value
        let temp: String
        if tempValue <= 0.33 {
            temp = "cold"
        } else if tempValue <= 0.66 {
            temp = "hot"
        } else {
            temp = "veryHot"
        }
        
        stock.temp = temp
        CoreDataManager.shared.saveContext()
        navigationController?.popViewController(animated: true)
    }
    
    //This is my added feature, that allows the user to share a stock as text.
    //When the user presses the share button, the visible stock details can be shared as text. 
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        // Prepare the items to share
        var itemsToShare: [Any] = []
        
        var statsString="Name of Stock: \(nameRow.textLabel?.text ?? "unkown") \n\(lowPriceRow.textLabel?.text ?? "N/A") \n\(highPriceRow.textLabel?.text ?? "N/A") \n\(lastPriceRow.textLabel?.text ?? "N/A") \n\(perNetChangeRow.textLabel?.text ?? "N/A")"
        itemsToShare.append(statsString)
        
        // Create a UIActivityViewController
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        // Exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .saveToCameraRoll]
        
        // Present the activity view controller
        present(activityViewController, animated: true, completion: nil)
    }
}
