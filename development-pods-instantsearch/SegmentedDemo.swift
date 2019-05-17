//
//  SegmentedDemo.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 13/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore

class SegmentedDemo: UIViewController {

  let genderAttribute = Attribute("gender")

  var genderViewModel: SelectableSegmentViewModel<Int, Filter.Facet>!

  let mainStackView = UIStackView(frame: .zero)
  let segmentedControl = UISegmentedControl(frame: .zero)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
    // Gender segmented control
    
    genderViewModel = SelectableSegmentViewModel(items: [:])
    genderViewModel.items = [
      0: Filter.Facet(attribute: genderAttribute, stringValue: "male"),
      1: Filter.Facet(attribute: genderAttribute, stringValue: "female")
    ]
//    genderViewModel.selected = 0
    
    sc = SegmentedController<Filter.Facet>(segmentedControl: segmentedControl)
    genderViewModel.connectController(sc)
  }
  
  var sc: SegmentedController<Filter.Facet>!
  
}

extension SegmentedDemo: SearcherPluggable {
  
  func plug<R>(_ searcher: SingleIndexSearcher<R>) where R : Decodable, R : Encodable {
    genderViewModel.connectSearcher(searcher, attribute: genderAttribute, operator: .or)
  }
  
}

private extension SegmentedDemo {
  
  func setupUI() {
    configureMainStackView()
    segmentedControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    mainStackView.addArrangedSubview(segmentedControl)
    
    view.addSubview(mainStackView)
    
    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      ])
  }
  
  func configureMainStackView() {
    mainStackView.axis = .horizontal
    mainStackView.spacing = .px16
    mainStackView.distribution = .equalCentering
    mainStackView.alignment = .top
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
  }
  
}
