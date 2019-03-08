//
//  Helpers.swift
//  development-pods-instantsearch
//
//  Created by Guy Daher on 08/03/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit

public typealias TextChangeHandler = (String) -> Void

public class TextFieldWidget {

  var textChangeObservations = [TextChangeHandler]()

  public init (textField: UITextField) {
    textField.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
  }

  @objc func textFieldTextChanged(textField: UITextField) {
    guard let searchText = textField.text else { return }
    textChangeObservations.forEach { $0(searchText) }
  }

  public func subscribeToTextChangeHandler(using closure: @escaping TextChangeHandler) {
    textChangeObservations.append(closure)
  }
}
