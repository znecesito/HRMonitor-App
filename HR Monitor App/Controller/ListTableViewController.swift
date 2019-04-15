//
//  ListTableViewController.swift
//  HR Monitor App
//
//  Created by Zackarin Necesito on 3/8/19.
//  Copyright © 2019 Zack Necesito. All rights reserved.
//

import UIKit
import CoreData

class ListTableViewController: UITableViewController {

    var heartRateList = [HeartRate]()
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return heartRateList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BPMCell", for: indexPath)
        
        cell.textLabel?.text = "\(heartRateList[indexPath.row].heartRate)"

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) 
    }
    
    func loadItems(){
        
        let request : NSFetchRequest<HeartRate> = HeartRate.fetchRequest()

        let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        request.predicate = predicate

        do {
            heartRateList = try context.fetch(request)
        } catch  {
            print("Error fetching data: \(error)")
        }
            
    }


}
