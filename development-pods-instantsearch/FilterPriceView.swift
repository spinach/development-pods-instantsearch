//
//  FilterPriceView.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 05/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearchCore
import UIKit

class FilterPriceController: NumberView {

  typealias Item = Double

  func setItem(item: Double) {
    stepper.value = item
  }

  func setComputation<Number>(computation: Computation<Number>) where Number : Numeric {
    //stepper.addTarget(self, action: #selector(stepperAction), for: <#T##UIControl.Event#>)


  }

  let stepper: UIStepper

  public init(stepper: UIStepper) {
    self.stepper = stepper
  }
  
}
