//
//  RefinementList.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 11/03/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore

class RefinementListController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  private let ALGOLIA_APP_ID = "latency"
  private let ALGOLIA_INDEX_NAME = "bestbuy_promo"
  private let ALGOLIA_API_KEY = "1f6fd3a6fb973cb08419fe7d288fa4db"

  var refinementListViewModel: RefinementListViewModel!
  var tableView = UITableView()
  var textFieldWidget: TextFieldWidget!
  let textField = UITextField()
  var searcher: SingleIndexSearcher<JSON>!
  var searcherSFFV: SearchForFacetValueSearcher!
  var client: Client!
  var index: Index!
  var filterBuilder: FilterBuilder!
  var query: Query!

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self

    tableView.translatesAutoresizingMaskIntoConstraints = false
    textField.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(tableView)
    self.view.addSubview(textField)

    textField.backgroundColor = .gray

    textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
    textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
    textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    textField.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 0).isActive = true
    textField.heightAnchor.constraint(equalToConstant: 40).isActive = true

    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")

    textFieldWidget = TextFieldWidget(textField: textField)
    client = Client(appID: ALGOLIA_APP_ID, apiKey: ALGOLIA_API_KEY)
    index = client.index(withName: ALGOLIA_INDEX_NAME)
    refinementListViewModel = RefinementListViewModel(attribute: Attribute("category"), filterBuilder: filterBuilder)
    refinementListViewModel.settings.operator = .and
    refinementListViewModel.settings.areMultipleSelectionsAllowed = true
    searcherSFFV = SearchForFacetValueSearcher(index: index, query: query, filterBuilder: filterBuilder, facetName: "category", text: "")

    textFieldWidget.subscribeToTextChangeHandler { (text) in
      self.query.page = 0
      self.searcherSFFV.setQuery(text: text)
      self.searcherSFFV.search()
    }

    self.searcherSFFV.onSearchResults.subscribe(with: self) { [weak self] (result) in
      switch result {
      case .success(let result): self?.refinementListViewModel.update(with: result)
      case .fail(let error):
        print(error)
        break
      }

      self?.tableView.reloadData()
    }


    self.searcher.onSearchResults.subscribePast(with: self) { [weak self] (queryMetada, result) in
      switch result {
      case .success(let result): self?.refinementListViewModel.update(with: result)
      case .fail(let error):
        print(error)
        break
      }

      self?.tableView.reloadData()
    }

    self.refinementListViewModel.onParamChange.subscribe(with: self) { [weak self] in
      self?.query.page = 0
      self?.searcher.search()
    }
  }

  // MARK: - Table View

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return refinementListViewModel.numberOfRows()
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    refinementListViewModel.didSelectRow(indexPath.row)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)

    let facetValue = refinementListViewModel.facetForRow(indexPath.row)
    if let facetValue = facetValue {
      cell.textLabel?.text = "\(facetValue.value) (\(facetValue.count))"
      cell.accessoryType = refinementListViewModel.isRefined(indexPath.row) ? .checkmark : .none
    }
    return cell
  }
}
