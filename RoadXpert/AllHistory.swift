//
//  AllHistory.swift
//  RoadXpert
//
//  Created by Chelsey Bergmann on 12/13/20.
//

import UIKit
//protocol {
//    void setDataSource(String[] a)
//}


class HistoryViewCell:  UITableViewCell {

}

class AllHistory: UITableViewController {
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)

       // let restaurant = restaurants[indexPath.row]
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //nextVC.selectedResterant = restaurants[indexPath.row].name
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller.
       // nextVC = segue.destination as! ViewController
    }
}




