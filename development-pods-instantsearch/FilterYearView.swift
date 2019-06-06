//
//  FilterYearView.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 05/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore
import UIKit

class FilterYearController: NSObject, NumberView {

  typealias Item = Int

  func setItem(item: Int) {
    self.textField.text = "\(item)"
  }

  var computation: Computation<Int>?

  func setComputation(computation: Computation<Int>) {
    self.computation = computation
  }

  let textField: UITextField

  public init(textField: UITextField) {
    self.textField = textField
    super.init()
    textField.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
  }

  @objc func doneButtonTappedForMyNumericTextField() {
    guard let text = textField.text, let intText = Int(text) else { return }
    self.computation?.just(value: intText)
    textField.resignFirstResponder()
  }

}

extension UITextField {
  func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
    let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
    let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

    let toolbar: UIToolbar = UIToolbar()
    toolbar.barStyle = .default
    toolbar.items = [
      UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
      UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
    ]
    toolbar.sizeToFit()

    self.inputAccessoryView = toolbar
  }

  // Default actions:
  @objc func doneButtonTapped() { self.resignFirstResponder() }
  @objc func cancelButtonTapped() { self.resignFirstResponder() }
}
