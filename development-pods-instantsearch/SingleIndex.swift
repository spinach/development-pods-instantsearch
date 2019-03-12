//
//  MasterViewController.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 05/03/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import UIKit
import InstantSearchCore
import InstantSearchClient

class SingleIndexController: UIViewController, UITableViewDataSource {

  private let ALGOLIA_APP_ID = "latency"
  private let ALGOLIA_INDEX_NAME = "bestbuy_promo"
  private let ALGOLIA_API_KEY = "1f6fd3a6fb973cb08419fe7d288fa4db"

  let hitsViewModel = HitsViewModel<JSON>(hitsSettings: HitsViewModel.Settings())

  var tableView = UITableView()
  var textFieldWidget: TextFieldWidget!
  let textField = UITextField()
  var searcher: SingleIndexSearcher<JSON>!
  var client: Client!
  var index: Index!
  let query = Query()

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self

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
    searcher = SingleIndexSearcher(index: index, query: query)
    query.facets = ["category"]
    searcher.search()


    textFieldWidget.subscribeToTextChangeHandler { (text) in
      self.searcher.setQuery(text: text)
      self.searcher.search()
    }


    self.searcher.onSearchResults.subscribe(with: self) { [weak self] (queryMetada, result) in
      switch result {
      case .success(let result): self?.hitsViewModel.update(with: queryMetada, and: result)
      case .fail(let error):
        print(error)
        break
      }

      self?.tableView.reloadData()
    }

    self.hitsViewModel.onNewPage.subscribe(with: self) { [weak self] (page) in
      self?.searcher.query.page = UInt(page)
      self?.searcher.search()
    }
  }

  // MARK: - Table View

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsViewModel.numberOfRows()
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)

    let hit = hitsViewModel.hitForRow(indexPath.row)
    // TODO: the below should be done better
    let rawHit = [String: Any](hit!)
    cell.textLabel!.text = rawHit?["name"] as? String
    return cell
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "refinementListSegue") {
      let refinementListController = segue.destination as! RefinementListController
      refinementListController.searcher = searcher
      refinementListController.query = query
    }
  }

}
