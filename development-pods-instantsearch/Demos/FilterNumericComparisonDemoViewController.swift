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
  let priceAttribute = Attribute("price")

  let searcher: SingleIndexSearcher<JSON>

  let numberViewModel: NumberViewModel<Int>
  let numberViewModel2: NumberViewModel<Int>
  let numberViewModel3: NumberViewModel<Double>

  let searchStateViewController: SearchStateViewController

  let numberController: FilterYearController
  let numberController2: FilterYearController
  let numberController3: FilterPriceController

  let mainStackView = UIStackView(frame: .zero)
  let stepperStackView = UIStackView(frame: .zero)
  let stepperLabel = UILabel()

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.searcher = SingleIndexSearcher(index: .demo(withName:"mobile_demo_filter_numeric_comparison"))

    numberViewModel = NumberViewModel()
    numberViewModel2 = NumberViewModel()
    numberViewModel3 = NumberViewModel()

    let textField = UITextField()
    let textField2 = UITextField()
    textField.keyboardType = .numberPad
    textField2.keyboardType = .numberPad
    numberController = FilterYearController(textField: textField)
    numberController2 = FilterYearController(textField: textField2)
    
    let stepper = UIStepper()
    numberController3 = FilterPriceController(stepper: stepper)

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


    numberViewModel2.connectFilterState(searcher.filterState, attribute: yearAttribute, operator: .greaterThanOrEqual)
    numberViewModel2.connectView(view: numberController2)

    numberViewModel3.connectFilterState(searcher.filterState, attribute: priceAttribute, operator: .greaterThanOrEqual)
    numberViewModel3.connectView(view: numberController3)

    numberViewModel.connectSearcher(searcher, attribute: yearAttribute)
    numberViewModel2.connectSearcher(searcher, attribute: yearAttribute)
    numberViewModel3.connectSearcher(searcher, attribute: priceAttribute)

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

    numberController2.textField.layer.borderWidth = 1
    numberController2.textField.layer.borderColor = UIColor.gray.cgColor
    numberController2.textField.heightAnchor.constraint(equalToConstant: 40).isActive = true

    mainStackView.addArrangedSubview(numberController2.textField)

    numberController2.textField.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.4).isActive = true

    stepperStackView.addArrangedSubview(numberController3.stepper)
    stepperStackView.addArrangedSubview(stepperLabel)
    numberController3.stepper.addTarget(self, action: #selector(onStepperValueChanged), for: .valueChanged)
    mainStackView.addArrangedSubview(stepperStackView)

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

  @objc func onStepperValueChanged(sender: UIStepper) {
    stepperLabel.text = "\(sender.value)"
  }

  func configureMainStackView() {
    mainStackView.axis = .vertical
    mainStackView.spacing = .px16
    mainStackView.distribution = .fill
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.alignment = .center
  }

  func configureStepperStackView() {
    stepperStackView.axis = .horizontal
    stepperStackView.spacing = .px16
    stepperStackView.distribution = .fill
    stepperStackView.translatesAutoresizingMaskIntoConstraints = false
    stepperStackView.alignment = .center
  }

}
