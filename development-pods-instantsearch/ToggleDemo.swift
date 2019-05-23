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
import InstantSearch

class ToggleDemo: UIViewController {
  
  let promotionsAttribute = Attribute("promotions")

  var freeShippingViewModel: SelectableViewModel<Filter.Facet>!
  var sizeConstraintViewModel: SelectableViewModel<Filter.Numeric>!
  var vintageViewModel: SelectableViewModel<Filter.Tag>!
  var couponViewModel: SelectableViewModel<Filter.Facet>!

  var promotionsViewModel: SelectableFacetsViewModel!
  
  let mainStackView = UIStackView()
  let togglesStackView = UIStackView()
  let couponStackView = UIStackView()
  
  let freeShippingButton = UIButton(frame: .zero)
  let couponLabel = UILabel()
  let couponSwitch = UISwitch(frame: .zero)
  
  let sizeButton = UIButton(frame: .zero)
  let vintageButton = UIButton(frame: .zero)


  let promotionsTableView = UITableView(frame: .zero, style: .plain)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
    // Free shipping button
    
    let freeShipingFacet = Filter.Facet(attribute: promotionsAttribute, stringValue: "free shipping")
    freeShippingViewModel = SelectableViewModel(item: freeShipingFacet)
    let freeShippingButtonController = SelectableFilterButtonController<Filter.Facet>(button: freeShippingButton)
    freeShippingViewModel.connectController(freeShippingButtonController)
    
    // Size constraint button
    
    let sizeConstraintFilter = Filter.Numeric(attribute: "size", operator: .greaterThan, value: 40)
    sizeConstraintViewModel = SelectableViewModel(item: sizeConstraintFilter)
    let sizeConstraintButtonController = SelectableFilterButtonController<Filter.Numeric>(button: sizeButton)
    sizeConstraintViewModel.connectController(sizeConstraintButtonController)
    
    // Vintage tag button
    
    let vintageFilter = Filter.Tag(value: "vintage")
    vintageViewModel = SelectableViewModel(item: vintageFilter)
    let vintageButtonController = SelectableFilterButtonController<Filter.Tag>(button: vintageButton)
    vintageViewModel.connectController(vintageButtonController)
    
    
    // Coupon switch
    
    let couponFacet = Filter.Facet(attribute: promotionsAttribute, stringValue: "coupon")
    couponViewModel = SelectableViewModel<Filter.Facet>(item: couponFacet)
    
    let switchController = FilterSwitchController<Filter.Facet>(switch: couponSwitch)
    couponViewModel.connectController(switchController)
    

    
    // Promotions list
    
    promotionsViewModel = FacetListViewModel(selectionMode: .multiple)
    let promotionsController = FacetListTableController(tableView: promotionsTableView)
    promotionsViewModel.connectController(promotionsController)
    
    
  }
  
}

extension ToggleDemo: SearcherPluggable {
  
  func plug<R: Codable>(_ searcher: SingleIndexSearcher<R>) {
    freeShippingViewModel.connectFilterState(searcher.indexSearchData.filterState, operator: .or)
    couponViewModel.connectFilterState(searcher.indexSearchData.filterState, operator: .or)
    sizeConstraintViewModel.connectFilterState(searcher.indexSearchData.filterState, operator: .or)
    vintageViewModel.connectFilterState(searcher.indexSearchData.filterState, operator: .or)
    promotionsViewModel.connectFilterState(searcher.indexSearchData.filterState, with: promotionsAttribute, operator: .or)
  }
  
}

fileprivate extension ToggleDemo {
  
  func setupUI() {
    configureFreeShippingButton()
    configureSizeButton()
    configureVintageButton()
    configureCouponLabel()
    configureCouponSwitch()
    configureCouponStackView()
    configurePromotionsTableView()
    configureTogglesStackView()
    configureMainStackView()
    configureLayout()
  }
  
  func configureLayout() {
    view.addSubview(mainStackView)
    
    freeShippingButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    sizeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    vintageButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    couponStackView.addArrangedSubview(couponLabel)
    couponStackView.addArrangedSubview(couponSwitch)
    couponStackView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    togglesStackView.addArrangedSubview(freeShippingButton)
    togglesStackView.addArrangedSubview(couponStackView)
    togglesStackView.addArrangedSubview(sizeButton)
    togglesStackView.addArrangedSubview(vintageButton)
    mainStackView.addArrangedSubview(togglesStackView)
    mainStackView.addArrangedSubview(promotionsTableView)
    
    promotionsTableView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor).isActive = true

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
    mainStackView.distribution = .fillEqually
    mainStackView.alignment = .top
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func configureTogglesStackView() {
    togglesStackView.axis = .vertical
    togglesStackView.spacing = .px16
    togglesStackView.distribution = .equalCentering
    togglesStackView.alignment = .leading
    togglesStackView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func configureCheckBoxButton(_ button: UIButton, withTitle title: String) {
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(title, for: .normal)
    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
    button.setTitleColor(.black, for: .normal)
    button.setImage(UIImage(named: "square"), for: .normal)
    button.setImage(UIImage(named: "check-square"), for: .selected)
  }
  
  func configureFreeShippingButton() {
    configureCheckBoxButton(freeShippingButton, withTitle: "free shipping")
  }
  
  func configureSizeButton() {
    configureCheckBoxButton(sizeButton, withTitle: "size > 40")
  }
  
  func configureVintageButton() {
    configureCheckBoxButton(vintageButton, withTitle: "vintage")
  }
  
  func configureCouponSwitch() {
    couponSwitch.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func configureCouponLabel() {
    couponLabel.text = "Coupon"
    couponLabel.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func configureCouponStackView() {
    couponStackView.translatesAutoresizingMaskIntoConstraints = false
    couponStackView.axis = .horizontal
    couponStackView.spacing = .px16
    couponStackView.alignment = .center
    couponStackView.distribution = .fill
  }
  
  func configurePromotionsTableView() {
    promotionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
    promotionsTableView.alwaysBounceVertical = false
    promotionsTableView.tableHeaderView = UIView(frame: .zero)
    promotionsTableView.tableFooterView = UIView(frame: .zero)
    promotionsTableView.backgroundColor =  UIColor(hexString: "#f7f8fa")
  }
  
}
