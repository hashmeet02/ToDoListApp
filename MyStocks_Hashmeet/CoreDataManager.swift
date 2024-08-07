//
//  NetworkManager.swift
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

import CoreData
import UIKit

// This is the cor data manager class allowing persistant data storage
class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    //this is the container variable connection to CoreData
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyStocks_Hashmeet")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    //variable to store the context
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    //This function stores the changes to the containter
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //This function is used to add a stock to the container
    func addStock(symbol: String, name: String, price: Double, isActive: Bool, temp: String, performanceId: String) {
        let stock = StockEntity(context: context)
        stock.symbol = symbol
        stock.name = name
        stock.price = price
        stock.isActive = isActive
        stock.temp = temp
        stock.performanceId = performanceId
        stock.temp=temp
        
        saveContext()
    }
    
    //This function is used to delete a stock from the container.
    func deleteStock(stock: StockEntity){
        context.delete(stock)
        saveContext()
    }

    //This function gets a list of all stocks in the container. 
    func fetchStocks() -> [StockEntity] {
        let request: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch failed")
            return []
        }
    }
}
