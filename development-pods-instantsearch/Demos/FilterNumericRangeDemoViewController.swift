//
//  NumericRangeDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 14/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit
import InstantSearch
import InstantSearchCore
import WARangeSlider

class FilterNumericRangeDemoViewController: UIViewController {

  let priceAttribute = Attribute("price")

  let searcher: SingleIndexSearcher
  let filterState: FilterState

  let numberViewModel: NumberViewModel<Int>
  let numberViewModel2: NumberViewModel<Int>
  let numberViewModel3: NumberRangeViewModel<Double>
  let numberViewModel4: NumberRangeViewModel<Double>

  let searchStateViewController: SearchStateViewController

  let numericTextFieldController1: NumericTextFieldController
  let numericTextFieldController2: NumericTextFieldController
  let numericRangeController1: NumericRangeController
  let numericRangeController2: NumericRangeController

  let mainStackView = UIStackView(frame: .zero)
  let sliderStackView1 = UIStackView(frame: .zero)
  let sliderStackView2 = UIStackView(frame: .zero)
  let sliderLower1 = UILabel()
  let sliderUpper1 = UILabel()
  let sliderLower2 = UILabel()
  let sliderUpper2 = UILabel()

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.searcher = SingleIndexSearcher(index: .demo(withName:"mobile_demo_filter_numeric_comparison"))
    self.filterState = .init()
    numberViewModel = .init()
    numberViewModel2 = .init()
    numberViewModel3 = .init()
    numberViewModel4 = .init()

    let textField = UITextField()
    let textField2 = UITextField()
    textField.keyboardType = .numberPad
    textField2.keyboardType = .numberPad

    numericTextFieldController1 = NumericTextFieldController(textField: textField)
    numericTextFieldController2 = NumericTextFieldController(textField: textField2)
    numericRangeController1 = NumericRangeController(rangeSlider: .init())
    numericRangeController2 = NumericRangeController(rangeSlider: .init())

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


private extension FilterNumericRangeDemoViewController {

  func setup() {

    searcher.connectFilterState(filterState)

    numberViewModel.connectFilterState(filterState, attribute: priceAttribute, operator: .greaterThanOrEqual)
    numberViewModel.connectView(view: numericTextFieldController1)
    numberViewModel.connectSearcher(searcher, attribute: priceAttribute)

    numberViewModel2.connectFilterState(filterState, attribute: priceAttribute, operator: .lessThanOrEqual)
    numberViewModel2.connectView(view: numericTextFieldController2)
    numberViewModel2.connectSearcher(searcher, attribute: priceAttribute)

    numberViewModel3.connectFilterState(filterState, attribute: priceAttribute)
    numberViewModel3.connectView(view: numericRangeController1)
    numberViewModel3.connectSearcher(searcher, attribute: priceAttribute)

    numberViewModel4.connectFilterState(filterState, attribute: priceAttribute)
    numberViewModel4.connectView(view: numericRangeController2)
    numberViewModel4.connectSearcher(searcher, attribute: priceAttribute)

    searchStateViewController.connectSearcher(searcher)
    searchStateViewController.connectFilterState(filterState)

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

    numericTextFieldController1.textField.layer.borderWidth = 1
    numericTextFieldController1.textField.layer.borderColor = UIColor.gray.cgColor
    numericTextFieldController1.textField.heightAnchor.constraint(equalToConstant: 40).isActive = true

    mainStackView.addArrangedSubview(numericTextFieldController1.textField)

    numericTextFieldController1.textField.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.4).isActive = true

    numericTextFieldController2.textField.layer.borderWidth = 1
    numericTextFieldController2.textField.layer.borderColor = UIColor.gray.cgColor
    numericTextFieldController2.textField.heightAnchor.constraint(equalToConstant: 40).isActive = true

    mainStackView.addArrangedSubview(numericTextFieldController2.textField)

    numericTextFieldController2.textField.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.4).isActive = true

    configureHorizontalStackView(sliderStackView1)
    configureHorizontalStackView(sliderStackView2)

    sliderLower1.widthAnchor.constraint(equalToConstant: 50).isActive = true
    sliderLower2.widthAnchor.constraint(equalToConstant: 50).isActive = true
    sliderUpper1.widthAnchor.constraint(equalToConstant: 50).isActive = true
    sliderUpper2.widthAnchor.constraint(equalToConstant: 50).isActive = true

    numericRangeController1.rangerSlider.heightAnchor.constraint(equalToConstant: 50).isActive = true
    numericRangeController1.rangerSlider.widthAnchor.constraint(equalToConstant: 500).isActive = true
    sliderStackView1.addArrangedSubview(sliderLower1)
    sliderStackView1.addArrangedSubview(numericRangeController1.rangerSlider)
    sliderStackView1.addArrangedSubview(sliderUpper1)
    numericRangeController1.rangerSlider.addTarget(self, action: #selector(onSlider1ValueChanged), for: .valueChanged)
    sliderStackView1.heightAnchor.constraint(equalToConstant: 50).isActive = true
    mainStackView.addArrangedSubview(sliderStackView1)

    numericRangeController2.rangerSlider.heightAnchor.constraint(equalToConstant: 50).isActive = true
    numericRangeController2.rangerSlider.widthAnchor.constraint(equalToConstant: 500).isActive = true
    sliderStackView2.addArrangedSubview(sliderLower2)
    sliderStackView2.addArrangedSubview(numericRangeController2.rangerSlider)
    sliderStackView2.addArrangedSubview(sliderUpper2)
    numericRangeController2.rangerSlider.addTarget(self, action: #selector(onSlider2ValueChanged), for: .valueChanged)
    mainStackView.addArrangedSubview(sliderStackView2)

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

  @objc func onSlider1ValueChanged(sender: RangeSlider) {
    sliderLower1.text = "\(sender.lowerValue.rounded(toPlaces: 2))"
    sliderUpper1.text = "\(sender.upperValue.rounded(toPlaces: 2))"
  }

  @objc func onSlider2ValueChanged(sender: RangeSlider) {
    sliderLower2.text = "\(sender.lowerValue.rounded(toPlaces: 2))"
    sliderUpper2.text = "\(sender.upperValue.rounded(toPlaces: 2))"
  }

  func configureMainStackView() {
    mainStackView.axis = .vertical
    mainStackView.spacing = .px16
    mainStackView.distribution = .fill
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.alignment = .center
  }

  func configureHorizontalStackView(_ stackView: UIStackView) {
    stackView.axis = .horizontal
    stackView.spacing = .px16
    stackView.distribution = .fill
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .center
    
  }

}

extension Double {
  /// Rounds the double to decimal places value
  func rounded(toPlaces places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}
