//
//  PotentialInstantSearch.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 14/03/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore

//extension HitsViewModel {
//
//  func connectTo(_ searcher: SingleIndexSearcher<RecordType>) {
//    searcher.onSearchResults.subscribe(with: self) { [weak self] (queryMetada, result) in
//      switch result {
//      case .success(let result): self?.update(with: queryMetada, and: result)
//      case .fail(let error):
//        print(error)
//        break
//      }
//    }
//
//    searcher.connectTo(hitsViewModel: self)
//  }
//
//  func connectTo(_ tableView: UITableView) {
//    self.onUpdate.subscribePast(with: self) { _ in
//      tableView.reloadData()
//    }
//  }
//
//}
//
//extension SingleIndexSearcher {
//  func connectTo<T>(hitsViewModel: HitsViewModel<T>) {
//    hitsViewModel.onNewPage.subscribe(with: self) { [weak self] (page) in
//      self?.query.page = UInt(page)
//      self?.search()
//    }
//  }
//}
//
//extension UITableView: HitsWidget {
//  func reload() {
//    reloadData()
//  }
//}
//
//protocol HitsWidget: class {
//  func reload()
//}
//
//extension HitsWidget {
//  func connectTo<T>(hitsViewModel: HitsViewModel<T>) {
//    hitsViewModel.onUpdate.subscribePast(with: self) { [weak self] _ in
//      self?.reload()
//    }
//  }
//}
