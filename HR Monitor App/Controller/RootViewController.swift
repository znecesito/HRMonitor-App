//
//  RootViewController.swift
//  HR Monitor App
//
//  Created by Zackarin Necesito on 3/8/19.
//  Copyright © 2019 Zack Necesito. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        let MainVC = storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        present(MainVC, animated: true, completion: nil)
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
