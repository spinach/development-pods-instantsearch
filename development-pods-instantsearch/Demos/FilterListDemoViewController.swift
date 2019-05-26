//
//  FilterListDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 26/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore
import InstantSearch

class FilterListDemoViewController: UIViewController {
  
  let facetFilters: [Filter.Facet] = [
    .init(attribute: "f1", stringValue: "v1"),
    .init(attribute: "f2", stringValue: "v2"),
    .init(attribute: "f3", stringValue: "v3"),
  ]
  
  let numericFilters: [Filter.Numeric] = [
    .init(attribute: "size", range: 32...42),
    .init(attribute: "price", operator: .greaterThan, value: 100),
    .init(attribute: "count", operator: .equals, value: 20),
  ]
  
  let tagFilters = (0...5).map { Filter.Tag(value: "Tag \($0)") }
  
  let filterListViewModel: FilterListViewModel<Filter.Tag>
  let filterListController: FilterListTableController<Filter.Tag>
  let filterStateViewController: SearchStateViewController
  
  init() {
    filterListViewModel = FilterListViewModel(items: tagFilters)
    filterListController = FilterListTableController(tableView: .init())
    filterStateViewController = SearchStateViewController()
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
}

private extension FilterListDemoViewController {
  
  func setup() {
    filterListViewModel.connectController(filterListController)
//    filterStateViewController.connectTo()
  }
  
  func setupUI() {
    
    let mainStackView = UIStackView()
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.axis = .vertical
    mainStackView.spacing = .px16
    
    view.addSubview(mainStackView)
    
    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo:view.topAnchor),
      mainStackView.bottomAnchor.constraint(equalTo:view.topAnchor),
      mainStackView.leadingAnchor.constraint(equalTo:view.leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo:view.trailingAnchor),
    ])
    
    addChild(filterStateViewController)
    filterStateViewController.view.heightAnchor.constraint(equalToConstant: 150).isActive = true
    
    mainStackView.addArrangedSubview(filterStateViewController.view)
    mainStackView.addArrangedSubview(filterListController.tableView)
    
  }
  
}
