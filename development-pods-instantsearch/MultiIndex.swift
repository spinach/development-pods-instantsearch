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

class MultindexController: UIViewController, UITableViewDataSource {

  private let ALGOLIA_APP_ID = "latency"
  private let ALGOLIA_API_KEY = "1f6fd3a6fb973cb08419fe7d288fa4db"

  let actorViewModel = HitsViewModel<JSON>(infiniteScrolling: false)
  let movieViewModel = HitsViewModel<JSON>(infiniteScrolling: false)
  var hitsViewModels: [HitsViewModel<JSON>] = []

  var tableView = UITableView()
  var textFieldWidget: TextFieldWidget!
  let textField = UITextField()
  var searcher: MultiIndexSearcher!
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
    let actorsIndex = client.index(withName: "actors")
    let moviesIndex = client.index(withName: "movies")
    let indices = [actorsIndex, moviesIndex]
    searcher = MultiIndexSearcher(client: client, indices: indices, query: query)
    hitsViewModels = [actorViewModel, movieViewModel]

    searcher.search()

    textFieldWidget.subscribeToTextChangeHandler { (text) in
      self.searcher.setQuery(text: text)
      self.searcher.search()
    }


    self.searcher.onSearchResults.subscribe(with: self) { [weak self] (results) in
      guard let strongSelf = self else { return }
      for (searchResults, hitsViewModel) in zip(results, strongSelf.hitsViewModels) {
        // TODO: searchresults here also has queryMetadata, so need to re-introduce a new type
        switch searchResults.1 {
        case .success(let result): hitsViewModel.update(with: searchResults.0, and: result)
        case .fail:
          break
        }
      }
      strongSelf.tableView.reloadData()
    }
  }

  // MARK: - Table View

  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsViewModels[section].numberOfRows()
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)

    let hit = hitsViewModels[indexPath.section].hitForRow(indexPath.row)
    let rawHit = [String: Any](hit!)
    if indexPath.section == 0 { // actor
      cell.textLabel!.text = rawHit?["name"] as? String
    } else { // movie
      cell.textLabel!.text = rawHit?["title"] as? String
    }

    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Actors"
    } else {
      return "Movies"
    }
  }
}
