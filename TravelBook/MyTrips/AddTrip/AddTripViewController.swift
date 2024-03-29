//
//  AddTripViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-28.
//

import UIKit

class AddTripViewController: UITableViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let first = UINib(nibName: "PictureTableView", bundle: nil)
        let second = UINib(nibName: "NameAndDescriptionTableView", bundle: nil)
        tableView.register(first, forCellReuseIdentifier: "datacell3")
        tableView.register(second, forCellReuseIdentifier: "datacell4")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "datacell3", for: indexPath) as? PictureTableViewCell else {
                return UITableViewCell()
            }
            cell.chooseImage?.layer.masksToBounds = true
            cell.chooseImage?.layer.borderColor = UIColor.black.cgColor
            cell.chooseImage?.layer.borderWidth = 1
            cell.chooseImage?.layer.cornerRadius = 10.0
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "datacell4", for: indexPath) as? NameAndDescriptionTableViewCell else {
                return UITableViewCell()
            }
            if indexPath.row == 0 {
                cell.imageView?.image = UIImage(systemName: "tag")
                cell.textField?.placeholder = "Name of the trip"
            } else{
                cell.imageView?.image = UIImage(systemName: "line.3.horizontal")
                cell.textField?.placeholder = "Brief description of the trip"
            }
            cell.imageView?.tintColor = .black
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else {
            return 50
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
