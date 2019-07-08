//
//  HierarchicalDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 08/07/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore
import UIKit

class HierarchicalDemoViewController: UIViewController {

  struct HierarchicalCategory {
    static var base: Attribute = "hierarchicalCategories"
    static var lvl0: Attribute { return Attribute(rawValue: base.description + ".lvl0")  }
    static var lvl1: Attribute { return Attribute(rawValue: base.description + ".lvl1") }
    static var lvl2: Attribute { return Attribute(rawValue: base.description + ".lvl2") }
  }

  let order = [
    HierarchicalCategory.lvl0,
    HierarchicalCategory.lvl1,
    HierarchicalCategory.lvl2,
  ]

  let searcher: SingleIndexSearcher
  let filterState: FilterState
  let hierarchicalViewModel: HierarchicalViewModel
  let hierarchicalTableViewController: HierarchicalTableViewController

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    searcher = SingleIndexSearcher(index: .demo(withName: "mobile_demo_hierarchical"))
    filterState = .init()
    hierarchicalViewModel = HierarchicalViewModel(hierarchicalAttributes: order, separator: " > ")
    hierarchicalTableViewController = .init(style: .plain)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  func setup() {
    searcher.connectFilterState(filterState)
    hierarchicalViewModel.connectSearcher(searcher: searcher)
    hierarchicalViewModel.connectFilterState(filterState)
    hierarchicalViewModel.connectController(hierarchicalTableViewController)
    searcher.search()
  }

  func setupUI() {
    addChild(hierarchicalTableViewController)
    hierarchicalTableViewController.didMove(toParent: self)
    view.addSubview(hierarchicalTableViewController.view)
    hierarchicalTableViewController.view.pin(to: view.safeAreaLayoutGuide)
  }


}
