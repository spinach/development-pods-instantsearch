//
//  ToggleDefaultDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 12/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore
import InstantSearch

class ToggleDefaultDemoViewController: UIViewController {
  
  let searcher: SingleIndexSearcher
  let filterState: FilterState
  let searchStateViewController: SearchStateViewController
  
  let popularViewModel: SelectableViewModel<Filter.Facet>
  
  let mainStackView = UIStackView()
  
  let popularButtonController: SelectableFilterButtonController<Filter.Facet>
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    
    searcher = .init(index: .demo(withName: "mobile_demo_filter_toggle"))
    filterState = .init()
    searchStateViewController = .init()
    
    let popularFacet = Filter.Facet(attribute: "popular", boolValue: true)
    popularViewModel = SelectableViewModel<Filter.Facet>(item: popularFacet)
    popularButtonController = SelectableFilterButtonController(button: .init())
    
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    setup()
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setup() {
    
    //let popularDeselected = Filter.Facet(attribute: "popular", boolValue: false)

    searcher.connectFilterState(filterState)
    popularViewModel.connectFilterState(filterState)
    
    searchStateViewController.connectSearcher(searcher)
    searchStateViewController.connectFilterState(filterState)
    
    popularViewModel.connectController(popularButtonController)
    
    searcher.search()

  }
  
  func setupUI() {
    view.backgroundColor = .white
    configurePopularButton()
    configureMainStackView()
    configureLayout()
  }
  
  func configurePopularButton() {
    let button = popularButtonController.button
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Popular", for: .normal)
    button.titleEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: -5)
    button.setTitleColor(.black, for: .normal)
    button.setImage(UIImage(named: "square"), for: .normal)
    button.setImage(UIImage(named: "check-square"), for: .selected)
  }
  
  func configureMainStackView() {
    mainStackView.axis = .vertical
    mainStackView.alignment = .center
    mainStackView.spacing = .px16
    mainStackView.distribution = .fill
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func configureLayout() {
    
    view.addSubview(mainStackView)
    
    mainStackView.pin(to: view.safeAreaLayoutGuide)
    
    addChild(searchStateViewController)
    
    searchStateViewController.didMove(toParent: self)
    mainStackView.addArrangedSubview(searchStateViewController.view)
    
    NSLayoutConstraint.activate([
      searchStateViewController.view.heightAnchor.constraint(equalToConstant: 150),
      searchStateViewController.view.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.98)
      ])
    
    
    mainStackView.addArrangedSubview(popularButtonController.button)
    mainStackView.addArrangedSubview(.init())
    
  }
  
}
