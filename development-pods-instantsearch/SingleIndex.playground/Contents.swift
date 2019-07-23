//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import InstantSearchCore
class MyViewController : UIViewController, UITableViewDataSource {

  private let ALGOLIA_APP_ID = "latency"
  private let ALGOLIA_INDEX_NAME = "bestbuy_promo"
  private let ALGOLIA_API_KEY = "1f6fd3a6fb973cb08419fe7d288fa4db"

  let hitsInteractor = HitsInteractor<JSON>()

  var tableView = UITableView()
  var activityIndicator = UIActivityIndicatorView()
  let textField = UITextField()
  var searcher: SingleIndexSearcher<JSON>!
  var textFieldWidget: UITextField!
  var client: Client!
  var index: Index!
  let query = Query()
  let filterState = FilterState()


    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

      tableView.dataSource = self

      tableView.translatesAutoresizingMaskIntoConstraints = false
      textField.translatesAutoresizingMaskIntoConstraints = false
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(tableView)
      view.addSubview(textField)
      view.addSubview(activityIndicator)

      textField.backgroundColor = .white
      activityIndicator.style = .gray

      activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
      activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

      textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
      textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
      textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
      textField.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 0).isActive = true
      textField.heightAnchor.constraint(equalToConstant: 40).isActive = true

      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true

      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")

      textFieldWidget = UITextField()
      client = Client(appID: ALGOLIA_APP_ID, apiKey: ALGOLIA_API_KEY)
      index = client.index(withName: ALGOLIA_INDEX_NAME)
      searcher = SingleIndexSearcher(index: index, query: query, filterState: filterState)
      query.facets = ["category"]
      searcher.search()

      self.searcher.isLoading.subscribe(with: self) { (isLoading) in
        if isLoading {
          self.activityIndicator.startAnimating()
        } else {
          self.activityIndicator.stopAnimating()
        }

        }.onQueue(.main)

      self.searcher.onSearchResults.subscribe(with: self) { [weak self] (queryMetada, result) in
        switch result {
        case .success(let result): self?.hitsInteractor.update(result, with: queryMetada)
        case .fail(let error):
          print(error)
          break
        }

        self?.tableView.reloadData()
      }

      self.hitsInteractor.onNewPage.subscribe(with: self) { [weak self] (page) in
        self?.searcher.query.page = UInt(page)
        self?.searcher.search()
      }


        self.view = view
    }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hitsInteractor.numberOfRows()
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)

    let hit = hitsInteractor.hitForRow(indexPath.row)
    // TODO: the below should be done better
    let rawHit = [String: Any](hit!)
    cell.textLabel!.text = rawHit?["name"] as? String
    return cell
  }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

