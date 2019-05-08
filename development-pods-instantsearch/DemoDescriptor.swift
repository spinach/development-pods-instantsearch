//
//  DemoDescriptor.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 06/05/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import UIKit

struct DemoDescriptor {
  
  let appID: String
  let indexName: String
  let apiKey: String
  let controller: UIViewController & SearcherPluggable
  
  static let refinementList = DemoDescriptor(
    appID: "latency",
    indexName: "mobile_demo_refinement_facets",
    apiKey: "1f6fd3a6fb973cb08419fe7d288fa4db",
    controller: RefinementListDemo())
  
  static let toggle = DemoDescriptor(
    appID: "latency",
    indexName: "mobile_demo_refinement_filter",
    apiKey: "1f6fd3a6fb973cb08419fe7d288fa4db",
    controller: ToggleDemo())
  
  static let singleIndex = DemoDescriptor(appID: "latency", indexName: "bestbuy_promo", apiKey: "1f6fd3a6fb973cb08419fe7d288fa4db", controller: SingleIndexController())
  
}
