//
//  HierarchicalTableViewController.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 08/07/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore
import UIKit

class HierarchicalTableViewController: UITableViewController, HierarchicalController {

  var onClick: ((String) -> Void)?
  var items: [(Int, Facet)]
  private let cellID = "cellID"

  override init(style: UITableView.Style) {
    self.items = []
    super.init(style: style)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setItem(_ item: [[Facet]]) {

    self.items = item.enumerated()
      .map { index, items in
        items.map {
          item in (index, item)
        }
      }.flatMap { $0 }

    tableView.reloadData()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

    let item = items[indexPath.row]
    cell.textLabel?.text = "\(item.1.description) level: \(item.0)"
    cell.indentationLevel = item.0
    return cell

  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = items[indexPath.row]
    onClick?(item.1.value)
  }


}
