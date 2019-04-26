//
//  TableViewDataSource.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 26/04/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore
import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

  weak var tableView: UITableView?

  var selectableItems: [RefinementFacet] = []
  var onClick: ((RefinementFacet) -> ())?

  public init(tableView: UITableView) {
    self.tableView = tableView
    super.init()
    tableView.dataSource = self
    tableView.delegate = self
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return selectableItems.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    return UITableViewCell()
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectableItem = selectableItems[indexPath.row]

    self.onClick?(selectableItem)
  }

  public func onClickItem(onClick: @escaping ((RefinementFacet) -> ()) ) {
    self.onClick = onClick
  }

  func setSelectableItems(selectableItems: [RefinementFacet]) {
    self.selectableItems = selectableItems
    tableView?.reloadData()
  }
}
