//
//  CurrentFiltersDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 12/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearch
import InstantSearchCore
import UIKit

class CurrentFiltersDemoViewController: UIViewController {

  let filterState: FilterState
  let currentFiltersListViewModel: CurrentFiltersViewModel
  let currentFiltersListViewModel2: CurrentFiltersViewModel

  let currentFiltersController: CurrentFilterListTableController
  let currentFiltersController2: CurrentFilterListTableController

  let searchStateViewController: SearchStateViewController

  let tableView: UITableView
  let tableView2: UITableView

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    searchStateViewController = .init()
    filterState = .init()

    tableView = .init()
    tableView2 = .init()

    currentFiltersListViewModel = .init()
    currentFiltersListViewModel2 = .init()

    currentFiltersController = .init(tableView: tableView)
    currentFiltersController2 = .init(tableView: tableView2)

    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    setupUI()
  }

}

private extension CurrentFiltersDemoViewController {

  func setup() {

    let groupFacets = FilterGroup.ID.or(name: "filterFacets")
    let groupNumerics = FilterGroup.ID.and(name: "filterNumerics")


    currentFiltersListViewModel.connectFilterState(filterState)
    currentFiltersListViewModel.connectController(currentFiltersController)

    currentFiltersListViewModel2.connectFilterState(filterState, filterGroupID: groupFacets)
    currentFiltersListViewModel2.connectController(currentFiltersController2)


    searchStateViewController.connectFilterState(filterState)


    let filterFacet1 = Filter.Facet(attribute: "category", value: "table")
    let filterFacet2 = Filter.Facet(attribute: "category", value: "chair")

    filterState.add(filterFacet1, toGroupWithID: groupFacets)
    filterState.add(filterFacet2, toGroupWithID: groupFacets)

    let filterNumeric1 = Filter.Numeric(attribute: "price", operator: .greaterThan, value: 10)
    let filterNumeric2 = Filter.Numeric(attribute: "price", operator: .lessThan, value: 20)


    filterState.add(filterNumeric1, toGroupWithID: groupNumerics)
    filterState.add(filterNumeric2, toGroupWithID: groupNumerics)

    filterState.notifyChange()
  }

  func setupUI() {

    view.backgroundColor = .white

    let mainStackView = UIStackView()
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.axis = .vertical
    mainStackView.spacing = .px16

    view.addSubview(mainStackView)

    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor),
      mainStackView.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor),
      mainStackView.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor),
      ])

    addChild(searchStateViewController)
    searchStateViewController.didMove(toParent: self)
    searchStateViewController.view.heightAnchor.constraint(equalToConstant: 150).isActive = true

    //tableView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    tableView2.heightAnchor.constraint(equalToConstant: 300).isActive = true

    mainStackView.addArrangedSubview(searchStateViewController.view)
    mainStackView.addArrangedSubview(tableView)
    mainStackView.addArrangedSubview(tableView2)

  }

}
