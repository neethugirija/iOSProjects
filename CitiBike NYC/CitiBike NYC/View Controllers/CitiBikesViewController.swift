//
//  CitiBikesViewController.swift
//  CitiBike NYC
//
//  Created by Neethu G on 2/16/19.
//  Copyright © 2019 Neethu G. All rights reserved.
//

import UIKit

class CitiBikesViewController: UIViewController {
    let dataManager = DataManager()
    var stationList = [Station]()

    @IBOutlet weak var stationListTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        dataManager.getJsonData { (citibikes, error) in
            if let citibikesNYC = citibikes {
                self.stationList = citibikesNYC.stationBeanList
                DispatchQueue.main.async { self.stationListTableView.reloadData()}
            }
        }
    }

    //function to get station name
    func stationName(index: Int) -> String {
        return stationList[index].stationName
    }
}

// MARK: - Table view data source
extension CitiBikesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "citibikes") else {
            print("Wrong cell identifier")
            return UITableViewCell()
        }
        cell.textLabel?.text = stationName(index: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        tableView.sectionHeaderHeight = CGFloat(Constants.tableHeaderHeight)
        return Constants.tableHeader
    }
}


// MARK: - Table view delegate

extension CitiBikesViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row:\(indexPath.row)")
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.detailSegue,
            let stationDetailsVC = segue.destination as? StationDetailsViewController,
            let selectedIndex = stationListTableView.indexPathForSelectedRow?.row
        {
            stationDetailsVC.station = stationList[selectedIndex]
        }
    }
}

