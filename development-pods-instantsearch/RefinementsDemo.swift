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
import InstantSearch

protocol SearcherPluggable {
  func plug<R: Codable>(_ searcher: SingleIndexSearcher<R>)
  func plug(_ facetSearcher: FacetSearcher)
}

extension SearcherPluggable {
  func plug(_ facetSearcher: FacetSearcher) {
    // defaults to doing nothing
  }
}

class RefinementsDemo: UIViewController {

  let colorAttribute = Attribute("color")
  let promotionsAttribute = Attribute("promotions")
  let categoryAttribute = Attribute("category")

  var searcher: SingleIndexSearcher<JSON>!
  var facetSearcher: FacetSearcher!
  var client: Client!
  var index: Index!
  var filterState: FilterState = FilterState()
  var query: Query = Query()
  let filterStateViewController = FilterStateViewController()
  var clearRefinementsController: ClearRefinementsController!
  
  var demo: DemoDescriptor = .refinementList

  let mainStackView = UIStackView()
  let headerStackView = UIStackView()
  let clearRefinementsButton = UIButton(type: .custom)
  let titleLabel = UILabel()
  let hitsCountLabel = UILabel()
  let activityIndicator = UIActivityIndicatorView()
  var loadableController: ActivityIndicatorController!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor =  UIColor(hexString: "#f7f8fa")
    clearRefinementsController = ClearRefinementsButtonController(button: clearRefinementsButton)
    
    client = Client(appID: demo.appID, apiKey: demo.apiKey)
    index = client.index(withName: demo.indexName)
    searcher = SingleIndexSearcher(index: index, query: query, filterState: filterState)
    facetSearcher = FacetSearcher(index: index, query: query, filterState: filterState, facetName: colorAttribute.name)

    setupUI()
        
    searcher.search()

    loadableController = ActivityIndicatorController(activityIndicator: activityIndicator)
    searcher.connectController(loadableController)
    facetSearcher.connectController(loadableController)

    filterStateViewController.colorMap = [
      "_tags": UIColor(hexString: "#9673b4"),
      "size": UIColor(hexString: "#698c28"),
      colorAttribute.name: .red,
      promotionsAttribute.name: .blue,
      categoryAttribute.name: .green
    ]
    
    filterStateViewController.connectFilterState(searcher.indexSearchData.filterState)
    clearRefinementsController.connectFilterState(searcher.indexSearchData.filterState)
    
    searcher.onResultsChanged.subscribe(with: self) { (queryMetadata, result) in
      switch result {
      case .failure:
        self.filterStateViewController.stateLabel.text = "Network error"
      case .success(let results):
        self.hitsCountLabel.text = "hits: \(results.totalHitsCount)"
      }
    }
  }
}

extension RefinementsDemo {
  
  fileprivate func setupUI() {
    configureMainStackView()
    configureHeaderStackView()
    configureTitleLabel()
    configureHitsCountLabel()
    configureClearButton()
    configureActivityIndicator()
    configureLayout()    
  }
  
  func configureMainStackView() {
    mainStackView.axis = .vertical
    mainStackView.spacing = .px16
    mainStackView.distribution = .fill
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func configureClearButton() {
    clearRefinementsButton.setTitleColor(.black, for: .normal)
    clearRefinementsButton.setTitle("Clear", for: .normal)
    clearRefinementsButton.translatesAutoresizingMaskIntoConstraints = false
  }

  func configureActivityIndicator() {
    activityIndicator.style = .gray
    activityIndicator.hidesWhenStopped = false

  }
  
  func configureTitleLabel() {
    titleLabel.font = .boldSystemFont(ofSize: 25)
    titleLabel.text = "Filters"
  }
  
  func configureHitsCountLabel() {
    hitsCountLabel.textColor = .black
    hitsCountLabel.font = .systemFont(ofSize: 12)
  }
  
  func configureHeaderStackView() {
    headerStackView.axis = .vertical
    headerStackView.spacing = 10
    headerStackView.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    headerStackView.isLayoutMarginsRelativeArrangement = true
    headerStackView.distribution = .equalSpacing
    headerStackView.translatesAutoresizingMaskIntoConstraints = false
    headerStackView.addBackground(color: .white)
    headerStackView.alignment = .leading
    headerStackView.subviews.first.flatMap {
      $0.layer.borderWidth = 0.5
      $0.layer.borderColor = UIColor.black.cgColor
      $0.layer.masksToBounds = true
      $0.layer.cornerRadius = 10
    }
  }
  
  func configureLayout() {
    headerStackView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    
    headerStackView.addArrangedSubview(titleLabel)
    addChild(filterStateViewController)
    filterStateViewController.didMove(toParent: self)
    
    headerStackView.addArrangedSubview(filterStateViewController.stateLabel)
    headerStackView.addArrangedSubview(activityIndicator)
    headerStackView.addArrangedSubview(hitsCountLabel)
    
    mainStackView.addArrangedSubview(headerStackView)
    
    view.addSubview(mainStackView)
    
    NSLayoutConstraint.activate([
      mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .px16),
      mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.px16),
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
      mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),
    ])
    
    addChild(demo.controller)
    demo.controller.didMove(toParent: self)
    mainStackView.addArrangedSubview(demo.controller.view)
    
    demo.controller.plug(searcher)
    demo.controller.plug(facetSearcher)
    
    view.addSubview(clearRefinementsButton)
    
    NSLayoutConstraint.activate([
      clearRefinementsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
      clearRefinementsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
      ])
  }
  
}


