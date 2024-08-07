//
//  HomeTableViewController.swift
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
import CoreData

//This is the home table view Contoller
class HomeTableViewController: UITableViewController {
    var activeStocks = [StockEntity]()  //variable to store the list of activeStocks
    var watchStocks = [StockEntity]()   //variable to store the list of watchListStocks.

    //Function called when view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchStocks()       //Stocks are fetched from the core data container.
        navigationItem.leftBarButtonItem = editButtonItem   //set left Bar button to edit button.
        
        //Added refresh control to the table view controller.
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    //When view is about to appear, the table is updated with latest info from the stock container.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchStocks()
        tableView.reloadData()
        
    }
    
    // function called when page is refreshed.
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Fetch the latest stocks from the API
        fetchLatestStockData { [weak self] in
            self?.fetchStocks()
            self?.tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }

    //Fetch Stocks functions gets all the stocks from the core data container and puts them into 2 lists,
    // 1 for active stocks and 2nd for watchlist stocks.
    func fetchStocks() {
        let stocks = CoreDataManager.shared.fetchStocks()
        activeStocks = stocks.filter { $0.isActive }
        watchStocks = stocks.filter { !$0.isActive }
        tableView.reloadData()
    }
    
    //This function gets the lates prices for the stocks from the api and also updates them in the core data container.
    func fetchLatestStockData(completion: @escaping () -> Void) {
        let allStocks = CoreDataManager.shared.fetchStocks()
        let group = DispatchGroup()
        
        for stock in allStocks {
            guard let performanceId = stock.performanceId else { continue }
            group.enter()
            NetworkManager.shared.fetchStockDetails(performanceId: performanceId) { stockDetails in
                if let stockDetails = stockDetails {
                    stock.price = stockDetails.lastPrice
                    // Update other stock properties if needed
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            CoreDataManager.shared.saveContext()
            completion()
            self.fetchStocks()
            self.tableView.reloadData()
        }
    }

    //2 sections of Table for
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    //1st section is for active stocks and 2nd is for watch list stocks.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? activeStocks.count : watchStocks.count
    }
    
    //set headings for the 2 table sections.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return section==0 ? "Active List 🟢" : "Watch List 👀"
    }

    //sets the data of each table cell (sets stock name, price and image based on ranking/category)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath)
        let stock = indexPath.section == 0 ? activeStocks[indexPath.row] : watchStocks[indexPath.row]
        cell.textLabel?.text = stock.name
        cell.detailTextLabel?.text = "\(stock.price)"
        switch stock.temp {
        case "cold":
            cell.imageView?.image=UIImage(systemName: "snow" )
            cell.imageView?.tintColor = .blue
            cell.backgroundColor = .cold
        case "hot":
            cell.imageView?.image=UIImage(systemName: "sun.min.fill")
            cell.imageView?.tintColor = .systemOrange
            cell.backgroundColor = .hot
        case "veryHot":
            cell.imageView?.image=UIImage( systemName: "flame")
            cell.imageView?.tintColor = .red
            cell.backgroundColor = .veryHot
        default:
            return cell
            
        }
        
        return cell
    }
    
    //Editing style set.
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    //Editing enabled.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //this function enables swipe to delete on a table row. deletion also changes the list and updates the core data container.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let stock = indexPath.section == 0 ? activeStocks.remove(at: indexPath.row) : watchStocks.remove(at: indexPath.row)
            CoreDataManager.shared.context.delete(stock)
            CoreDataManager.shared.saveContext()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //This function enable drag and drop functionality. It allows user to change the category of stock (active/watching) by dragging
    // and dropping in between sections.
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == destinationIndexPath.section {
            if sourceIndexPath.section == 0 {
                let movedStock = activeStocks.remove(at: sourceIndexPath.row)
                activeStocks.insert(movedStock, at: destinationIndexPath.row)
            } else {
                let movedStock = watchStocks.remove(at: sourceIndexPath.row)
                watchStocks.insert(movedStock, at: destinationIndexPath.row)
            }
        } else {
            let movedStock: StockEntity
            if sourceIndexPath.section == 0 {
                movedStock = activeStocks.remove(at: sourceIndexPath.row)
                movedStock.isActive = false
                watchStocks.insert(movedStock, at: destinationIndexPath.row)
            } else {
                movedStock = watchStocks.remove(at: sourceIndexPath.row)
                movedStock.isActive = true
                activeStocks.insert(movedStock, at: destinationIndexPath.row)
            }
            CoreDataManager.shared.saveContext()
        }
        tableView.reloadData()
    }
    
    //Function called when add stock bar button menu item is pressed, perfroms segue to the addStock scene
    @IBAction func addStockTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addStockVC = storyboard.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        navigationController?.pushViewController(addStockVC, animated: true)
    }
    
    //Function called when segue is being performed to EditStock page. 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditStock",
           let destinationVC = segue.destination as? EditStockTableViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            let stock = indexPath.section == 0 ? activeStocks[indexPath.row] : watchStocks[indexPath.row]
            destinationVC.stock = stock
        }
    }


}
