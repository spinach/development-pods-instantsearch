//
//  DemoListViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 26/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit

class DemoListViewController: UITableViewController {
  
  enum Demo: CaseIterable {
    
    case singleIndex
    case sffv
    case toggle
    case facetList
    case segmented
    
    var title: String {
      switch self {
      case .singleIndex:
        return "Single index"
        
      case .sffv:
        return "Search for facet values"
        
      case .toggle:
        return "Toggle filters"
        
      case .facetList:
        return "Facet list"
        
      case .segmented:
        return "Segmented filters"
      }
    }

    var viewController: UIViewController {
      
      let viewController: UIViewController
      
      switch self {
      case .singleIndex:
        viewController = SingleIndexDemoViewController()
      case .sffv:
        viewController = FacetSearchDemoViewController()
      case .toggle:
        viewController = ToggleDemoViewController()
      case .facetList:
        viewController = RefinementListDemoViewController()
        
      case .segmented:
        viewController = SegmentedDemoViewController()
      }
      
      viewController.title = title
      
      return viewController
      
    }
    
  }
  
  
  private let cellIdentifier = "cellID"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Demo.allCases.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    cell.textLabel?.text = Demo.allCases[indexPath.row].title
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let demo = Demo.allCases[indexPath.row]
    navigationController?.show(demo.viewController, sender: self)
  }
  
}
