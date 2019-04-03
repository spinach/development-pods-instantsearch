//
//  MasterViewController.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 05/03/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import UIKit
import InstantSearchClient
import InstantSearch
import InstantSearchCore

class MultindexController: UIViewController {

  private let ALGOLIA_APP_ID = "latency"
  private let ALGOLIA_API_KEY = "1f6fd3a6fb973cb08419fe7d288fa4db"

  var tableView = UITableView()
  let textField = UITextField()
  var client: Client!
  var index: Index!
  var multiHitsController: MultiHitsController<TableViewMultiHitsWidget>!
  var tableViewHitsWidget: TableViewMultiHitsWidget!
  var textFieldWidget: TextFieldWidget!

  override func viewDidLoad() {
    super.viewDidLoad()

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
    tableViewHitsWidget = TableViewMultiHitsWidget(tableView: tableView)
    let actorsIndex = client.index(withName: "actors")
    let moviesIndex = client.index(withName: "movies")
    
    let dataSource = MITableViewMultiHitsDataSource()
    
    tableViewHitsWidget.dataSource = dataSource
    tableViewHitsWidget.delegate = MITableViewMultiHitsDelegate()
    
    multiHitsController = MultiHitsController(client: client, widget: tableViewHitsWidget)
    multiHitsController.register(IndexSearchData(index: actorsIndex), with: Actor.self)
    multiHitsController.register(IndexSearchData(index: moviesIndex), with: Movie.self)
    
    multiHitsController.searcher.search()
    
    textFieldWidget.subscribeToTextChangeHandler { (text) in
      self.multiHitsController.searcher.setQuery(text: text)
      self.multiHitsController.searcher.search()
    }

  }

}

class MITableViewMultiHitsDataSource: TableViewMultiHitsDataSource {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return hitsSource?.numberOfSections() ?? 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsSource?.numberOfHits(inSection: section) ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)

    guard let hitsSource = hitsSource else {
      return cell
    }
    
    switch indexPath.section {
    case 0:
      if let actor = try? hitsSource.hit(atIndex: indexPath.row, inSection: indexPath.section) as Actor? {
        cell.textLabel?.text = actor.name
      }
      
    case 1:
      if let movie = try? hitsSource.hit(atIndex: indexPath.row, inSection: indexPath.section) as Movie? {
        cell.textLabel?.text = movie.title
      }
      
    default:
      break
    }
    return cell

  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
    switch section {
    case 0:
      return "Actors"
      
    case 1:
      return "Movies"
      
    default:
      return nil
    }
  }
  
}

class MITableViewMultiHitsDelegate: TableViewMultiHitsDelegate {

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    guard let hitsSource = hitsSource else {
      return
    }
    
    switch indexPath.section {
    case 0:
      if let actor = try? hitsSource.hit(atIndex: indexPath.row, inSection: indexPath.section) as Actor? {
        print("Did select actor: \(actor.name)")
      }
      
    case 1:
      if let movie = try? hitsSource.hit(atIndex: indexPath.row, inSection: indexPath.section) as Movie? {
        print("Did select movie: \(movie.title)")
      }
      
    default:
      break
    }

  }

}

struct Actor: Codable {
  let name: String
}

struct Movie: Codable {
  let title: String
}
