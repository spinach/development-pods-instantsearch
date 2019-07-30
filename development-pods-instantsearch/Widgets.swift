//
//  Widgets.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 30/07/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch

public class SearchBar {
  
  let searchBar: UISearchBar
  private let queryInputInteractor: QueryInputInteractor
  private let searchBarController: SearchBarController
  
  init(searcher: SingleIndexSearcher, searchTriggeringMode: SearchTriggeringMode = .searchAsYouType) {
    self.searchBar = UISearchBar()
    self.queryInputInteractor = .init()
    self.searchBarController = .init(searchBar: searchBar)
    setup(with: searcher, using: searchTriggeringMode)
  }
  
  private func setup(with searcher: SingleIndexSearcher,
                     using searchTriggeringMode: SearchTriggeringMode) {
    queryInputInteractor.connectSearcher(searcher, searchTriggeringMode: searchTriggeringMode)
    queryInputInteractor.connectController(searchBarController)
  }
  
}

public class HitsTable<HitType: Codable> {
  
  public let tableView: UITableView
  private let hitsInteractor: HitsInteractor<HitType>
  private let hitsTableController: HitsTableController<HitsInteractor<HitType>>
  private let cellID: String
  private let dataSource: HitsTableViewDataSource<HitsInteractor<HitType>>
  private let delegate: HitsTableViewDelegate<HitsInteractor<HitType>>
  
  public init<Cell: UITableViewCell>(with searcher: SingleIndexSearcher,
                                     infiniteScrolling: InfiniteScrolling,
                                     showItemsOnEmptyQuery: Bool,
                                     cell: Cell,
                                     configuration: @escaping (HitType, Cell) -> Void,
                                     selection: @escaping (HitType) -> Void) {
    self.tableView = UITableView()
    self.hitsInteractor = .init(infiniteScrolling: infiniteScrolling, showItemsOnEmptyQuery: showItemsOnEmptyQuery)
    self.hitsTableController = HitsTableController(tableView: tableView)
    self.cellID = "cellID"
    dataSource = HitsTableViewDataSource()  { tableView, hit, indexPath -> UITableViewCell in
      let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
      (cell as? Cell).flatMap { configuration(hit, $0) }
      return cell
    }
    delegate = HitsTableViewDelegate() { _, hit, _ in
      selection(hit)
    }
    
    hitsTableController.dataSource = self.dataSource
    hitsTableController.delegate = self.delegate
    tableView.register(Cell.self, forCellReuseIdentifier: cellID)
  }
  
}
