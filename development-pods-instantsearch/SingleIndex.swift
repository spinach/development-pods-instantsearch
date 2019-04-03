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
import InstantSearch

struct Item: Codable {
  let name: String
}

class SingleIndexController: UIViewController {

  private let ALGOLIA_APP_ID = "latency"
  private let ALGOLIA_INDEX_NAME = "bestbuy_promo"
  private let ALGOLIA_API_KEY = "1f6fd3a6fb973cb08419fe7d288fa4db"

  let tableView: UITableView = UITableView()
  let activityIndicator = UIActivityIndicatorView()
  let textField = UITextField()
  var client: Client!
  var tableWidget: TableViewHitsWidget<Item>!
  var textFieldWidget: TextFieldWidget!
  var hitsController: HitsController<TableViewHitsWidget<Item>>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.client = Client(appID: ALGOLIA_APP_ID, apiKey: ALGOLIA_API_KEY)
    self.tableWidget = TableViewHitsWidget<Item>(tableView: tableView)
    self.textFieldWidget = TextFieldWidget(textField: textField)
    
    self.tableWidget.dataSource = SITableViewDataSource()
    self.tableWidget.delegate = SITableViewDelegate()
    
    self.hitsController = HitsController(index: client.index(withName: ALGOLIA_INDEX_NAME), widget: tableWidget)
    
    configureLayout()
    
    hitsController.searcher.indexSearchData.query.facets = ["category"]
    
    hitsController.onError.subscribe(with: self) { [weak self] error in
      DispatchQueue.main.async {
        let errorController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: .none)
        errorController.addAction(okAction)
        self?.present(errorController, animated: true, completion: .none)
      }
    }
    
    hitsController.searcher.isLoading.subscribe(with: self) { (isLoading) in
      if isLoading {
        self.activityIndicator.startAnimating()
      } else {
        self.activityIndicator.stopAnimating()
      }
    }.onQueue(.main)
    
    textFieldWidget.subscribeToTextChangeHandler(using: hitsController.searchWithQueryText)
    
    hitsController.searcher.search()
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "refinementListSegue") {
      let refinementListController = segue.destination as! RefinementListController
      refinementListController.searcher = self.hitsController.searcher
      refinementListController.filterBuilder = self.hitsController.searcher.indexSearchData.filterBuilder
      refinementListController.query = self.hitsController.searcher.indexSearchData.query
    }
  }
  
}

class SITableViewDataSource<DS: HitsSource>: TableViewHitsDataSource<DS> where DS.Record == Item {

  init() {
    super.init { _,_,_ in return UITableViewCell() }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsSource?.numberOfHits() ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let hit = hitsSource?.hit(atIndex: indexPath.row)
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)
    cell.textLabel?.text = hit?.name
    return cell
  }

}

class SITableViewDelegate<DS: HitsSource>: TableViewHitsDelegate<DS> where DS.Record == Item {

  init() {
    super.init { _, _, _ in }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let hit = hitsSource?.hit(atIndex: indexPath.row) else { return }
    print("Did click \(hit.name)")
  }

}

private extension SingleIndexController {
  
  private func configureLayout() {
    view.addSubview(tableView)
    view.addSubview(textField)
    view.addSubview(activityIndicator)
    configureTableViewLayout()
    configureTextFieldLayout()
    configureActivityIndicator()
  }
  
  private func configureActivityIndicator() {
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.style = .gray
    NSLayoutConstraint.activate([
      activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
      activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    ])
  }
  
  private func configureTextFieldLayout() {
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.backgroundColor = .white
    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
      textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
      textField.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 0),
      textField.heightAnchor.constraint(equalToConstant: 40),
    ])
  }
  
  private func configureTableViewLayout() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
      ])
  }
  
}
