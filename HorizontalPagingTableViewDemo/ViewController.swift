//
//  ViewController.swift
//  HorizontalPagingTableViewDemo
//
//  Created by Travis Ma on 3/8/18.
//  Copyright © 2018 Travis Ma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var horizontalPagingTable: HorizontalPagingTableView!
    let words = [
        "Hello1","Hello2","Hello3","Hello4","Hello5","Hello6","Hello7","Hello1","Hello2","Hello3","Hello4","Hello5","Hello6","Hello7"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        horizontalPagingTable.layer.borderColor = UIColor.blue.cgColor
        horizontalPagingTable.layer.borderWidth = 4
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        horizontalPagingTable.setup(viewController: self, totalItemCount: words.count, itemHeight: 60, delegate: self)
    }

}

extension ViewController: HorizontalPagingTableViewDelegate {
    
    func horizontalPagingTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, dataIndex: Int) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Blah")
        cell.textLabel?.text = words[dataIndex]
        cell.detailTextLabel?.text = "Table Index \(indexPath.row)"
        return cell
    }
    
}
