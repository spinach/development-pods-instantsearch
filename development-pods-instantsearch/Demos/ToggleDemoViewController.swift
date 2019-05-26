//
//  ToggleDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 03/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore
import InstantSearch

class ToggleDemoViewController: UIViewController {
  
  let promotionsAttribute = Attribute("promotions")

  let searcher: SingleIndexSearcher<JSON>
  let headerViewControler: SearchStateViewController
  
  let freeShippingViewModel: SelectableViewModel<Filter.Facet>
  let sizeConstraintViewModel: SelectableViewModel<Filter.Numeric>
  let vintageViewModel: SelectableViewModel<Filter.Tag>
  let couponViewModel: SelectableViewModel<Filter.Facet>
  let promotionsViewModel: SelectableFacetsViewModel
  
  let mainStackView = UIStackView()
  let widgetsStackView = UIStackView()
  let togglesStackView = UIStackView()
  let couponStackView = UIStackView()
  
  let freeShippingButtonController: SelectableFilterButtonController<Filter.Facet>
  let vintageButtonController: SelectableFilterButtonController<Filter.Tag>
  let sizeConstraintButtonController: SelectableFilterButtonController<Filter.Numeric>
  let couponSwitchController: FilterSwitchController<Filter.Facet>
  let promotionsController: FacetListTableController
  
  let couponLabel = UILabel()
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    
    let client = Client(appID: "latency", apiKey: "1f6fd3a6fb973cb08419fe7d288fa4db")
    let index = client.index(withName: "mobile_demo_filter_toggle")
    searcher = SingleIndexSearcher(index: index)
    headerViewControler = SearchStateViewController()
    
    // Free shipping button
    
    let freeShipingFacet = Filter.Facet(attribute: promotionsAttribute, stringValue: "free shipping")
    freeShippingViewModel = SelectableViewModel(item: freeShipingFacet)
    freeShippingButtonController = SelectableFilterButtonController(button: .init())
    
    // Size constraint button
    
    let sizeConstraintFilter = Filter.Numeric(attribute: "size", operator: .greaterThan, value: 40)
    sizeConstraintViewModel = SelectableViewModel(item: sizeConstraintFilter)
    sizeConstraintButtonController = SelectableFilterButtonController(button: .init())
    
    // Vintage tag button
    
    let vintageFilter = Filter.Tag(value: "vintage")
    vintageViewModel = SelectableViewModel(item: vintageFilter)
    vintageButtonController = SelectableFilterButtonController(button: .init())
    
    // Coupon switch
    
    let couponFacet = Filter.Facet(attribute: promotionsAttribute, stringValue: "coupon")
    couponViewModel = SelectableViewModel<Filter.Facet>(item: couponFacet)
    couponSwitchController = FilterSwitchController(switch: .init())
    
    // Promotions list
    
    promotionsViewModel = FacetListViewModel(selectionMode: .multiple)
    promotionsController = FacetListTableController(tableView: .init())
    
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


private extension ToggleDemoViewController {
  
  func setup() {
    let filterState = searcher.indexSearchData.filterState
    freeShippingViewModel.connectTo(filterState, operator: .or)
    couponViewModel.connectTo(filterState, operator: .or)
    sizeConstraintViewModel.connectTo(filterState, operator: .or)
    vintageViewModel.connectTo(filterState, operator: .or)
    promotionsViewModel.connectTo(searcher, with: promotionsAttribute)
    promotionsViewModel.connectTo(filterState, with: promotionsAttribute, operator: .or)
    headerViewControler.connectTo(searcher)
    searcher.search()
    
    freeShippingViewModel.connectController(freeShippingButtonController)
    sizeConstraintViewModel.connectController(sizeConstraintButtonController)
    vintageViewModel.connectController(vintageButtonController)
    couponViewModel.connectController(couponSwitchController)
    promotionsViewModel.connectController(promotionsController)

  }
  
  func setupUI() {
    view.backgroundColor = .white
    configureFreeShippingButton()
    configureSizeButton()
    configureVintageButton()
    configureCouponLabel()
    configureCouponSwitch()
    configureCouponStackView()
    configurePromotionsTableView()
    configureMainStackView()
    configureTogglesStackView()
    configureWidgetsStackView()
    configureLayout()
  }
  
  func configureLayout() {
    
    view.addSubview(mainStackView)
    
    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    
    addChild(headerViewControler)
    headerViewControler.view.heightAnchor.constraint(equalToConstant: 150).isActive = true
    headerViewControler.didMove(toParent: self)
    mainStackView.addArrangedSubview(headerViewControler.view)
    mainStackView.addArrangedSubview(widgetsStackView)
    
    freeShippingButtonController.button.heightAnchor.constraint(equalToConstant: 44).isActive = true
    sizeConstraintButtonController.button.heightAnchor.constraint(equalToConstant: 44).isActive = true
    vintageButtonController.button.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    couponStackView.addArrangedSubview(couponLabel)
    couponStackView.addArrangedSubview(couponSwitchController.switch)
    couponStackView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    togglesStackView.addArrangedSubview(freeShippingButtonController.button)
    togglesStackView.addArrangedSubview(couponStackView)
    togglesStackView.addArrangedSubview(sizeConstraintButtonController.button)
    togglesStackView.addArrangedSubview(vintageButtonController.button)
    widgetsStackView.addArrangedSubview(togglesStackView)
    widgetsStackView.addArrangedSubview(promotionsController.tableView)
    
    promotionsController.tableView.heightAnchor.constraint(equalTo: widgetsStackView.heightAnchor).isActive = true

  }
  
  func configureMainStackView() {
    mainStackView.axis = .vertical
    mainStackView.spacing = .px16
    mainStackView.distribution = .fill
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
  }

  
  func configureWidgetsStackView() {
    widgetsStackView.axis = .horizontal
    widgetsStackView.spacing = .px16
    widgetsStackView.distribution = .fillEqually
    widgetsStackView.alignment = .top
    widgetsStackView.translatesAutoresizingMaskIntoConstraints = false
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
    configureCheckBoxButton(freeShippingButtonController.button, withTitle: "free shipping")
  }
  
  func configureSizeButton() {
    configureCheckBoxButton(sizeConstraintButtonController.button, withTitle: "size > 40")
  }
  
  func configureVintageButton() {
    configureCheckBoxButton(vintageButtonController.button, withTitle: "vintage")
  }
  
  func configureCouponSwitch() {
    couponSwitchController.switch.translatesAutoresizingMaskIntoConstraints = false
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
    let tableView = promotionsController.tableView
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
    tableView.alwaysBounceVertical = false
    tableView.tableHeaderView = UIView(frame: .zero)
    tableView.tableFooterView = UIView(frame: .zero)
    tableView.backgroundColor =  UIColor(hexString: "#f7f8fa")
  }
  
}
