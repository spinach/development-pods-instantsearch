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

struct TitleDescriptor {
  let text: String
  let color: UIColor
}

class FacetsController: NSObject, RefinementFacetsViewController {

  var onClick: ((Facet) -> Void)?

  var tableView: UITableView

  var selectableItems: [RefinementFacet] = []
  let titleDescriptor: TitleDescriptor?

  let px16: CGFloat = 16

  public init(tableView: UITableView, titleDescriptor: TitleDescriptor? = nil) {
    self.tableView = tableView
    self.titleDescriptor = titleDescriptor
    super.init()
    tableView.dataSource = self
    tableView.delegate = self
  }

  // MARK: RefinementFacetsViewController protocol

  func setSelectableItems(selectableItems: [RefinementFacet]) {
    self.selectableItems = selectableItems
  }

  func reload() {
    tableView.reloadData()
  }

}

extension FacetsController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return selectableItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)
    
    let selectableRefinement: RefinementFacet = selectableItems[indexPath.row]
    
    let facetAttributedString = NSMutableAttributedString(string: selectableRefinement.item.value)
    let facetCountStringColor = [NSAttributedString.Key.foregroundColor: UIColor.gray, .font: UIFont.systemFont(ofSize: 14)]
    let facetCountString = NSAttributedString(string: " (\(selectableRefinement.item.count))", attributes: facetCountStringColor)
    facetAttributedString.append(facetCountString)
    
    cell.textLabel?.attributedText = facetAttributedString
    
    cell.accessoryType = selectableRefinement.isSelected ? .checkmark : .none
    
    return cell
  }
  
}

extension FacetsController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectableItem = selectableItems[indexPath.row]
    
    self.onClick?(selectableItem.item)
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    guard let titleDescriptor = titleDescriptor else { return nil }
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 3 * px16))
    let label = UILabel(frame: CGRect(x: 5, y: px16, width: tableView.frame.width, height: 2 * px16))
    label.font = .systemFont(ofSize: 12)
    label.numberOfLines = 2
    label.textAlignment = .center
    view.addSubview(label)
    view.backgroundColor = UIColor(hexString: "#f7f8fa")
    label.textColor = .gray
    
    label.text = titleDescriptor.text
    label.textColor = titleDescriptor.color
    
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard titleDescriptor != nil else { return 0 }
    return 3 * px16
  }
  
}
