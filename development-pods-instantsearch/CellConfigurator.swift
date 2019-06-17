//
//  CellConfigurator.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 12/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import SDWebImage
import InstantSearchCore

protocol CellConfigurable {
  associatedtype T
  static func configure(_ cell: UITableViewCell) -> (T) -> Void
}

struct EmptyCellConfigurator: CellConfigurable {
  static func configure(_ cell: UITableViewCell) -> (Any) -> Void {
    return { _ in }
  }
}

struct MovieCellConfigurator: CellConfigurable {
  static func configure(_ cell: UITableViewCell) -> (Movie) -> Void {
    return { movie in
      cell.textLabel?.text = movie.title
      cell.detailTextLabel?.text = movie.genre.joined(separator: ", ")
      cell.imageView?.sd_setImage(with: movie.image, completed: { (_, _, _, _) in
        cell.setNeedsLayout()
      })
    }
  }
}

struct ActorCellConfigurator: CellConfigurable {
  static func configure(_ cell: UITableViewCell) -> (Actor) -> Void {
    return { actor in
      cell.textLabel?.text = actor.name
      cell.detailTextLabel?.text = "rating: \(actor.rating)"
      let baseImageURL = URL(string: "https://image.tmdb.org/t/p/w45")
      let imageURL = baseImageURL?.appendingPathComponent(actor.image_path)
      cell.imageView?.sd_setImage(with: imageURL, completed: { (_, _, _, _) in
        cell.setNeedsLayout()
      })
    }
  }

}

struct MovieHitCellConfigurator: CellConfigurable {
  
  static func configure(_ cell: UITableViewCell) -> (Hit<Movie>) -> Void {
    return { movieHit in
      let movie = movieHit.object
      if let highlightedTitles = movieHit.highlightResult?["title"] {
        let str = NSAttributedString(highlightedResults: highlightedTitles, separator: NSAttributedString(string: ", "), attributes: [.foregroundColor: UIColor.red])
        cell.textLabel?.attributedText = str
      }
      
      cell.detailTextLabel?.text = movie.genre.joined(separator: ", ")
      cell.imageView?.sd_setImage(with: movie.image, completed: { (_, _, _, _) in
        cell.setNeedsLayout()
      })
    }
  }
}
