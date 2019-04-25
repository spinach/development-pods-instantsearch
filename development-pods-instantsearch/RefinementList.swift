////
////  RefinementList.swift
////  development-pods-instantsearch
////
////  Created by Guy Daher on 11/03/2019.
////  Copyright © 2019 Algolia. All rights reserved.
////
//
//import Foundation
//import UIKit
//import InstantSearchCore
//
//class RefinementListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//
//  private let ALGOLIA_APP_ID = "latency"
//  private let ALGOLIA_INDEX_NAME = "bestbuy_promo"
//  private let ALGOLIA_API_KEY = "1f6fd3a6fb973cb08419fe7d288fa4db"
//
//  var refinementListViewModel: RefinementListViewModel!
//  var syncRefinementListViewModel: RefinementListViewModel!
//  var refinementFacetsViewModel: RefinementFacetsViewModel!
//  var tableView = UITableView()
//  var textFieldWidget: TextFieldWidget!
//  var toggle = UISwitch()
//  let textField = UITextField()
//  var searcher: SingleIndexSearcher<JSON>!
//  var searcherSFFV: FacetSearcher!
//  var client: Client!
//  var index: Index!
//  var filterState: FilterState!
//  var query: Query!
//  var sortedFacetValues: [SelectableRefinement] = []
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//
//    tableView.dataSource = self
//    tableView.delegate = self
//
//    tableView.translatesAutoresizingMaskIntoConstraints = false
//    textField.translatesAutoresizingMaskIntoConstraints = false
//    toggle.translatesAutoresizingMaskIntoConstraints = false
//    self.view.addSubview(tableView)
//    self.view.addSubview(textField)
//    self.view.addSubview(toggle)
//
//    textField.backgroundColor = .gray
//
//    textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
//    textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
//    textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
//    textField.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 0).isActive = true
//    textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
//
//    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
//    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
//    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
//
//    toggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
//    toggle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
//
//    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
//
//    textFieldWidget = TextFieldWidget(textField: textField)
//    client = Client(appID: ALGOLIA_APP_ID, apiKey: ALGOLIA_API_KEY)
//    index = client.index(withName: ALGOLIA_INDEX_NAME)
//
//
//    refinementFacetsViewModel = RefinementFacetsViewModel(selectionMode: .multiple)
//    refinementFacetsViewModel.connect(attribute: Attribute("category"), searcher: searcher, operator: .or)
//
//    refinementFacetsViewModel.onValuesChanged.subscribe(with: self) { [weak self] (facetValues) in
//      let refinementListPresenter = RefinementListPresenter()
//      self?.sortedFacetValues = refinementListPresenter.processFacetValues(selectedValues: Array(self?.refinementFacetsViewModel.selections ?? Set()), resultValues: facetValues, sortBy: [.isRefined, .count(order: .descending), .alphabetical(order: .ascending)])
//      self?.tableView.reloadData()
//    }
//
//
////    refinementListViewModel = RefinementListViewModel(attribute: Attribute("category"), filterState: filterState)
////    syncRefinementListViewModel = RefinementListViewModel(attribute: Attribute("category"), filterState: filterState)
////    // when "and" + "true", we get a bug in result list, page offset by 1?
////    // When we use "and" + "true", it's the only time we are actually doing a .search() and not .searchDisjunctiveFaceting()
////    //refinementListViewModel.settings.operator = .and(selection: .multiple)
////    refinementListViewModel.settings.operator = .or
////    refinementListViewModel.settings.sortBy = [.isRefined, .count(order: .descending), .alphabetical(order: .ascending)]
////
////    syncRefinementListViewModel.settings.operator = .or
////    syncRefinementListViewModel.settings.sortBy = [.isRefined, .count(order: .descending), .alphabetical(order: .ascending)]
////
////
////    searcherSFFV = FacetSearcher(index: index, query: query, filterState: filterState, facetName: "category", text: "")
////
////    textFieldWidget.subscribeToTextChangeHandler { (text) in
////      self.query.page = 0
////      self.searcherSFFV.setQuery(text: text)
////      self.searcherSFFV.search()
////    }
////
////    self.searcherSFFV.onSearchResults.subscribe(with: self) { [weak self] arg in
////
////      let (_, result) = arg
////
////      switch result {
////      case .success(let result):
////        self?.refinementListViewModel.update(with: result)
////        self?.syncRefinementListViewModel.update(with: result)
////
////      case .failure(let error):
////        print(error)
////        break
////      }
////
////      self?.tableView.reloadData()
////    }
////
////
////    self.searcher.onSearchResults.subscribePast(with: self) { [weak self] (queryMetada, result) in
////      switch result {
////      case .success(let result):
////        self?.refinementListViewModel.update(with: result)
////        self?.syncRefinementListViewModel.update(with: result)
////      case .failure(let error):
////        print(error)
////        break
////      }
////
////    }
////
////    self.refinementListViewModel.onExecuteNewSearch.subscribe(with: self) { [weak self] in
////      self?.query.page = 0
////      self?.searcher.search()
////    }
////
////    self.refinementListViewModel.onReloadView.subscribe(with: self) { [weak self] in
////        self?.tableView.reloadData()
////    }
////
////    self.refinementListViewModel.onReloadView.subscribe(with: self) {
////      // self?.tableView.reloadData()
////      print("Reloading of the actual second table")
////    }
//  }
//
//  // MARK: - Table View
//
//  func numberOfSections(in tableView: UITableView) -> Int {
//    return 1
//  }
//
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return sortedFacetValues.count
//  }
//
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    refinementFacetsViewModel.select(key: sortedFacetValues[indexPath.row].item.value)
//  }
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)
//
//    let selectableRefinement: SelectableRefinement = sortedFacetValues[indexPath.row]
//
//    cell.textLabel?.text = "\(selectableRefinement.item.value) (\(selectableRefinement.item.count))"
//    cell.accessoryType = selectableRefinement.isSelected ? .checkmark : .none
//
//    return cell
//  }
//
//  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//    if section == 0 {
//      return "Refinement List 1"
//    } else {
//      return "Refinement List 2"
//    }
//  }
//}
