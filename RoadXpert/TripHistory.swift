//
//  TripHistory.swift
//  RoadXpert
//
//  Created by Chelsey Bergmann on 10/14/20.
//

import UIKit

class TripHistory: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let label = UILabel()
        label.frame = CGRect(x:30, y: 50, width: UIScreen.main.bounds.width, height: 100)
        label.text = "Trip History"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 25.0, weight: .bold)
    
        view.addSubview(label)
     
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
