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

  let hitsViewModel = MultiHitsViewModel()

  var tableView = UITableView()
  var textFieldController: TextFieldController!
  let textField = UITextField()
  var searcher: MultiIndexSearcher!
  var client: Client!
  var index: Index!
  let query = Query()
  let filterState = FilterState()

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

    textFieldController = TextFieldController(textField: textField)
    client = Client(appID: ALGOLIA_APP_ID, apiKey: ALGOLIA_API_KEY)
    let actorsIndex = client.index(withName: "actors")
    let moviesIndex = client.index(withName: "movies")
    let indices = [actorsIndex, moviesIndex]
    
    searcher = MultiIndexSearcher(client: client, indices: indices, query: query, filterState: filterState)
    let actorViewModel = HitsViewModel<Actor>(infiniteScrolling: .off)
    let movieViewModel = HitsViewModel<Movie>(infiniteScrolling: .off)
    hitsViewModel.append(actorViewModel)
    hitsViewModel.append(movieViewModel)

    searcher.search()

    textFieldController.onSearch = { text in
      self.searcher.setQuery(text: text)
      self.searcher.search()
    }

    self.searcher.onResultsChanged.subscribe(with: self) { [weak self] result in
      
      guard let strongSelf = self else { return }
      
      switch result {
      case .success(let searchResults):
        do {
          try strongSelf.hitsViewModel.update(searchResults)
        } catch let error {
          print(error)
        }
        
      case .failure(let error):
        print(error)
      }

      strongSelf.tableView.reloadData()
    }
  }

  // MARK: - Table View

  func numberOfSections(in tableView: UITableView) -> Int {
    return hitsViewModel.numberOfSections()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsViewModel.numberOfHits(inSection: section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)

    let cellText: String?
    
    switch indexPath.section {
    case 0:
      let actor: Actor? = try! hitsViewModel.hit(at: indexPath)
      cellText = actor?.name
      
    case 1:
      let movie: Movie? = try! hitsViewModel.hit(at: indexPath)
      cellText = movie?.title
      
    default:
      cellText = ""
    }
    
    cell.textLabel?.text = cellText

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

extension MultindexController {
  
  struct Actor: Codable {
    let name: String
  }
  
  struct Movie: Codable {
    let title: String
  }
  
}
