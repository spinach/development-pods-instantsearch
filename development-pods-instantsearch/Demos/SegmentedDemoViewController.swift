//
//  SegmentedDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 13/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore

class SegmentedDemoViewController: UIViewController {

  let genderAttribute = Attribute("gender")
  
  let searcher: SingleIndexSearcher<JSON>

  let genderViewModel: SelectableSegmentViewModel<Int, Filter.Facet>
  let segmentedController: SegmentedController<Filter.Facet>
  let searchStateViewController: SearchStateViewController

  let mainStackView = UIStackView(frame: .zero)
  
  let male = Filter.Facet(attribute: "gender", stringValue: "male")
  let female = Filter.Facet(attribute: "gender", stringValue: "female")
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    let client = Client(appID: "latency", apiKey: "1f6fd3a6fb973cb08419fe7d288fa4db")
    let index = client.index(withName: "mobile_demo_filter_segment")
    self.searcher = SingleIndexSearcher(index: index)
    let items: [Int: Filter.Facet] = [
      0: male,
      1: female
    ]
    self.genderViewModel = SelectableSegmentViewModel(items: items)
    self.searchStateViewController = SearchStateViewController()
    segmentedController = SegmentedController<Filter.Facet>(segmentedControl: .init())
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
  
}


private extension SegmentedDemoViewController {
  
  func setup() {
    genderViewModel.connectTo(searcher, attribute: genderAttribute, operator: .or)
    genderViewModel.connectController(segmentedController)
    searchStateViewController.connectTo(searcher)
    searcher.filterState.notify(.add(filter: male, toGroupWithID: .or(name: genderAttribute.name))) 
    searcher.search()
  }
  
  func setupUI() {
    view.backgroundColor = .white
    configureMainStackView()
    
    addChild(searchStateViewController)
    searchStateViewController.didMove(toParent: self)
    searchStateViewController.view.heightAnchor.constraint(equalToConstant: 150).isActive = true

    mainStackView.addArrangedSubview(searchStateViewController.view)
    searchStateViewController.view.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 1).isActive = true

    segmentedController.segmentedControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    mainStackView.addArrangedSubview(segmentedController.segmentedControl)
    segmentedController.segmentedControl.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.9).isActive = true

    let spacerView = UIView()
    spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
    mainStackView.addArrangedSubview(spacerView)
    
    view.addSubview(mainStackView)
    
    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }
  
  func configureMainStackView() {
    mainStackView.axis = .vertical
    mainStackView.spacing = .px16
    mainStackView.distribution = .fill
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.alignment = .center
  }
  
}
