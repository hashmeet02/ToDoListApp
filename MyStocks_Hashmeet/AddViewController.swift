//
//  AddViewController.swift
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

//This is the AddViewController that allows searching adding capabilities.
class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    //variables to store stocks and filtered stocks.
    var stocks = [Stock]()
    var filteredStocks = [Stock]()

    //Setting delegate and dataSource for search bar and tableview.
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    //Whenever searchBar text changes, the api is called to retrieve a list of stocks with a name like that.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredStocks = stocks
            tableView.reloadData()
        } else {
            NetworkManager.shared.fetchStocks(query: searchText) { [weak self] result in
                guard let self = self, let result = result else { return }
                self.filteredStocks = result
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    //number of rows are equal to number of items in filtered stock list.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStocks.count
    }

    //setting stock name and symbol for cell rows.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath)
        let stock = filteredStocks[indexPath.row]
        cell.textLabel?.text = stock.name
        cell.detailTextLabel?.text = stock.ticker
        return cell
    }

    //when the user selects a stock, they are presented with an alert asking which list they want to add the stock to
    //they can cancel too. Added stock is also stored into the core data container.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let stock = filteredStocks[indexPath.row]
            
            let alert = UIAlertController(title: "Add Stock", message: "Add to Active List or Watch List?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Active List", style: .default, handler: { _ in
                self.addStock(stock: stock, isActive: true)
            }))
            alert.addAction(UIAlertAction(title: "Watch List", style: .default, handler: { _ in
                self.addStock(stock: stock, isActive: false)
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true, completion: nil)
        }

        private func addStock(stock: Stock, isActive: Bool) {
            NetworkManager.shared.addStock(stock: stock, isActive: isActive) { success in
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    // Handle error
                    print("Failed to add stock")
                }
            }
        }
}

