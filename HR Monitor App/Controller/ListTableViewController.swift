//
//  ListTableViewController.swift
//  HR Monitor App
//
//  Created by Zackarin Necesito on 3/8/19.
//  Copyright © 2019 Zack Necesito. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class ListTableViewController: UITableViewController{

    let emailController = MFMailComposeViewController()
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func exportButtonPressed(_ sender: UIBarButtonItem) {
        
        let fileName = "HRMdata"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName).appendingPathExtension("csv")
        
        var csvText = "\(selectedCategory?.name ?? "Entry")"
        print("\(fileURL)")
        
        if heartRateList.count > 0{
            
            for item in heartRateList{
                let newLine = "\n\(item.heartRate)"
                csvText.append(contentsOf: newLine)
            }
            
            do {
                try csvText.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                
                showMailComposer(fileURL, fileName)
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
        
        } else {
            print("Error: BPM List does not exist")
        }
        
    }
    
    func showMailComposer(_ fileURL:URL, _ fileName:String) {
        
        guard MFMailComposeViewController.canSendMail() else {
            //show alert informinf user
            showMailError()
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["zacknecesito@gmail.com"])
        composer.setSubject("Export Data")
        composer.setMessageBody("Data is attached to this email", isHTML: false)
        
        do{
            let fileData = try Data(contentsOf: fileURL as URL)
            print("\(fileData) nonono \(fileURL)")
            composer.addAttachmentData(fileData, mimeType: "text/csv", fileName: fileName)
        } catch {
            print("Unable to load data: \(error)")
        }
        
        present(composer, animated: true)
        
    }
    
    func showMailError() {
        let sendEmailErrorAlert = UIAlertController(title: "Could not send email", message: "Device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendEmailErrorAlert.addAction(dismiss)
        self.present(sendEmailErrorAlert, animated: true, completion: nil)
    }
    
}

extension ListTableViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("User cancelled")
            break
            
        case .saved:
            print("Mail is saved by user")
            break
            
        case .sent:
            print("Mail is sent successfully")
            break
            
        case .failed:
            print("Sending mail is failed")
            break
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
}
