//
//  FilterNumericComparisonDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 05/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchCore

class FilterNumericComparisonDemoViewController: UIViewController {

  let yearAttribute = Attribute("year")

  let searcher: SingleIndexSearcher<JSON>

  let numberViewModel: NumberViewModel<Int>

  let searchStateViewController: SearchStateViewController

  let numberController: FilterYearController

  let mainStackView = UIStackView(frame: .zero)

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.searcher = SingleIndexSearcher(index: .demo(withName:"mobile_demo_filter_numeric_comparison"))

    numberViewModel = NumberViewModel()

    let textField = UITextField()
    textField.keyboardType = .numberPad
    numberController = FilterYearController(textField: textField)

    self.searchStateViewController = SearchStateViewController()
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


private extension FilterNumericComparisonDemoViewController {

  func setup() {
    numberViewModel.connectFilterState(searcher.filterState, attribute: yearAttribute, operator: .greaterThanOrEqual)
    numberViewModel.connectView(view: numberController)
    searchStateViewController.connect(to: searcher)

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

    numberController.textField.layer.borderWidth = 1
    numberController.textField.layer.borderColor = UIColor.gray.cgColor
    numberController.textField.heightAnchor.constraint(equalToConstant: 40).isActive = true

    mainStackView.addArrangedSubview(numberController.textField)

    numberController.textField.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.4).isActive = true


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
