//
//  ViewController.swift
//  YNSearch
//
//  Created by YiSeungyoun on 2017. 4. 16..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import YNSearch
import InstantSearchCore

class YNDropDownMenu: YNSearchModel {
  var starCount = 512
  var description = "Awesome Dropdown menu for iOS with Swift 3"
  var version = "2.3.0"
  var url = "https://github.com/younatics/YNDropDownMenu"
}

class YNSearchData: YNSearchModel {
  var title = "YNSearch"
  var starCount = 271
  var description = "Awesome fully customize search view like Pinterest written in Swift 3"
  var version = "0.3.1"
  var url = "https://github.com/younatics/YNSearch"
}

class YNExpandableCell: YNSearchModel {
  var title = "YNExpandableCell"
  var starCount = 191
  var description = "Awesome expandable, collapsible tableview cell for iOS written in Swift 3"
  var version = "1.1.0"
  var url = "https://github.com/younatics/YNExpandableCell"
}

class ItemWrapper: YNSearchModel {
  
  let item: Item
  
  init(item: Item) {
    self.item = item
    super.init(key: item.name)
  }
  
}

class SearchHistoryController {
  
  private var searchHistory: [String] = []
  var limit: Int = 10
  
  func add(_ query: String) {
    if let index = searchHistory.firstIndex(of: query) {
      searchHistory.remove(at: index)
    }
    searchHistory.insert(query, at: 0)
    searchHistory = Array(searchHistory[0..<limit])
  }
  
  func clear() {
    searchHistory.removeAll()
  }
  
}

class ViewController: YNSearchViewController, YNSearchDelegate {
  
  private let ALGOLIA_APP_ID = "latency"
  private let ALGOLIA_INDEX_NAME = "bestbuy_promo"
  private let ALGOLIA_API_KEY = "1f6fd3a6fb973cb08419fe7d288fa4db"
  
  var refinementListViewModel: RefinementListViewModel!
  
  var searcher: SingleIndexSearcher<Item>!
  var facetSearcher: FacetSearcher!
  var client: Client!
  var index: Index!
  var filterBuilder = FilterBuilder()
  var query = Query()
  var hitsViewModel = HitsViewModel<Item>()
  var searchHistoryController = SearchHistoryController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)

    client = Client(appID: ALGOLIA_APP_ID, apiKey: ALGOLIA_API_KEY)
    index = client.index(withName: ALGOLIA_INDEX_NAME)
    refinementListViewModel = RefinementListViewModel(attribute: Attribute("category"), filterBuilder: filterBuilder)
    refinementListViewModel.settings.operator = .and(selection: .single)
    searcher = SingleIndexSearcher(index: index, query: query, filterBuilder: filterBuilder)
    query.facets = ["category"]
    
    searcher.onSearchResults.subscribe(with: self) { arg in
      let (md, result) = arg
      switch result {
      case .success(let searchResults):
        self.hitsViewModel.update(searchResults, with: md)
        self.refinementListViewModel.update(with: searchResults)
        
      case .failure:
        break
      }
      let demoCategories = (0..<self.refinementListViewModel.numberOfRows()).compactMap(self.refinementListViewModel.facetForRow).map { $0.value }
      
      let ynSearch = YNSearch()
      
      ynSearch.setCategories(value: demoCategories)
      self.ynSearchView?.removeFromSuperview()
      self.ynSearchTextfieldView?.removeFromSuperview()
      self.ynSearchinit()
      self.delegate = self
      
      let resultList = (0..<self.hitsViewModel.numberOfHits()).compactMap(self.hitsViewModel.hit(atIndex:)).map(ItemWrapper.init)
      
      self.initData(database: resultList)
      self.setYNCategoryButtonType(type: .colorful)
      


      
    }
    
    searcher.search()
    

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func ynSearchListViewDidScroll() {
    self.ynSearchTextfieldView.ynSearchTextField.endEditing(true)
  }
  
  
  func ynSearchHistoryButtonClicked(text: String) {
    ynSearchTextfieldView.ynSearchTextField.text = text
    textFieldDidBeginEditing(ynSearchTextfieldView.ynSearchTextField)
  }
  
  func ynCategoryButtonClicked(text: String) {
    filterBuilder.toggle(FilterFacet(attribute: "category", stringValue: text), in: AndFilterGroup(name: "cat"))
    searcher.search()
  }
  
  func ynSearchListViewClicked(key: String) {
    self.pushViewController(text: key)
    print(key)
  }
  
  func ynSearchListViewClicked(object: Any) {
    print(object)
  }
  
  func ynSearchListView(_ ynSearchListView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.ynSearchView.ynSearchListView.dequeueReusableCell(withIdentifier: YNSearchListViewCell.ID) as! YNSearchListViewCell
    if let ynmodel = self.ynSearchView.ynSearchListView.searchResultDatabase[indexPath.row] as? YNSearchModel {
      cell.searchLabel.text = ynmodel.key
    }
    
    return cell
  }
  
  func ynSearchListView(_ ynSearchListView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let ynmodel = self.ynSearchView.ynSearchListView.searchResultDatabase[indexPath.row] as? YNSearchModel, let key = ynmodel.key {
      self.ynSearchView.ynSearchListView.ynSearchListViewDelegate?.ynSearchListViewClicked(key: key)
      self.ynSearchView.ynSearchListView.ynSearchListViewDelegate?.ynSearchListViewClicked(object: self.ynSearchView.ynSearchListView.database[indexPath.row])
      self.ynSearchView.ynSearchListView.ynSearch.appendSearchHistories(value: key)
    }
  }
  
  func pushViewController(text:String) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "detail") as! DetailViewController
    vc.clickedText = text
    
    self.present(vc, animated: true, completion: nil)
  }
}

