//
//  ToggleDemo.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 03/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore

class ToggleDemo: UIViewController {
  
  let promotionsAttribute = Attribute("promotions")
  var freeShippingViewModel: SelectableViewModel<Filter.Facet>!
  var couponViewModel: SelectableViewModel<Filter.Facet>!
  var promotionsViewModel: SelectableFacetsViewModel!
  
  let freeShippingButton = UIButton(frame: .zero)
  let couponSwitch = UISwitch(frame: .zero)
  let promotionsTableView = UITableView(frame: .zero, style: .plain)
  
  let px16: CGFloat = 16
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
    let freeShipingFacet = Filter.Facet(attribute: promotionsAttribute, stringValue: "free shipping")
    freeShippingViewModel = SelectableViewModel<Filter.Facet>(item: freeShipingFacet)
    
    freeShippingButton.setTitle("Free shipping", for: .normal)
    freeShippingButton.setTitleColor(.gray, for: .normal)
    freeShippingButton.setTitleColor(.black, for: .selected)
    let buttonController = RefinementFilterButtonController<Filter.Facet>(button: freeShippingButton)
    
    freeShippingViewModel.connectViewController(buttonController)
    
    let couponFacet = Filter.Facet(attribute: promotionsAttribute, stringValue: "coupon")
    couponViewModel = SelectableViewModel<Filter.Facet>(item: couponFacet)
    
    let switchController = RefinementFilterSwitchController<Filter.Facet>(switch: couponSwitch)
    couponViewModel.connectViewController(switchController)
    
    promotionsViewModel = RefinementFacetsViewModel(selectionMode: .multiple)
    
    let promotionsController = FacetsController(tableView: promotionsTableView)
    
    promotionsViewModel.connectController(promotionsController)
    
  }
  
}

extension ToggleDemo: SearcherPluggable {
  
  func plug<R: Codable>(_ searcher: SingleIndexSearcher<R>) {
    freeShippingViewModel.connectSearcher(searcher, operator: .or)
    couponViewModel.connectSearcher(searcher, operator: .or)
    promotionsViewModel.connectSearcher(searcher, with: promotionsAttribute, operator: .or)
  }
  
}

extension ToggleDemo {
  
  func setupUI() {
    
    freeShippingButton.translatesAutoresizingMaskIntoConstraints = false
    couponSwitch.translatesAutoresizingMaskIntoConstraints = false
    
    let allWidgetsStackView = UIStackView()
    allWidgetsStackView.axis = .horizontal
    allWidgetsStackView.spacing = px16
    allWidgetsStackView.distribution = .fillEqually
    allWidgetsStackView.alignment = .top
    allWidgetsStackView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(allWidgetsStackView)
    
    let togglesStackView = UIStackView()
    togglesStackView.axis = .vertical
    togglesStackView.spacing = px16
    togglesStackView.distribution = .equalCentering
    togglesStackView.alignment = .leading
    togglesStackView.translatesAutoresizingMaskIntoConstraints = false
    
    freeShippingButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    togglesStackView.addArrangedSubview(freeShippingButton)
    
    let couponStackView = UIStackView()
    couponStackView.translatesAutoresizingMaskIntoConstraints = false
    couponStackView.axis = .horizontal
    couponStackView.spacing = px16
    couponStackView.distribution = .fill
    let couponLabel = UILabel()
    couponLabel.text = "Coupon"
    couponLabel.translatesAutoresizingMaskIntoConstraints = false
    couponStackView.addArrangedSubview(couponLabel)
    couponStackView.addArrangedSubview(couponSwitch)
    couponStackView.alignment = .center
    couponStackView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    togglesStackView.addArrangedSubview(couponStackView)
    
    allWidgetsStackView.addArrangedSubview(togglesStackView)
    allWidgetsStackView.addArrangedSubview(promotionsTableView)
    
    NSLayoutConstraint.activate([
      allWidgetsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      allWidgetsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      allWidgetsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      allWidgetsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    
    
    promotionsTableView.heightAnchor.constraint(equalTo: allWidgetsStackView.heightAnchor).isActive = true
    promotionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
    promotionsTableView.alwaysBounceVertical = false
    promotionsTableView.tableHeaderView = UIView(frame: .zero)
    promotionsTableView.tableFooterView = UIView(frame: .zero)
    promotionsTableView.backgroundColor =  UIColor(hexString: "#f7f8fa")
    
  }
  
}
