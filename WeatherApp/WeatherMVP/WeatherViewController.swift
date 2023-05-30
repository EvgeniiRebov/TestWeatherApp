//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 25.05.2023.
//

import UIKit

protocol ViewProtocol: AnyObject {
    func reloadData(_ history: [WeatherItem])
    func reloadData(_ newItem: WeatherItem)
    func showAlert()
}

class WeatherViewController: UIViewController, ViewProtocol {
    private enum Constants {
        static let cellId = String.init(describing: HistoryCell.self)
    }
    
    private let presenter: PresenterProtocol
    private let infoView = InfoView()
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private var history: [WeatherItem] = []
    
    init(presenter: PresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupSubviews()
        presenter.viewDidLoad()
    }
    
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "location.north.circle"),
                                                            style: .plain, target: self, action: #selector(requestWithLocation))
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = String.localize("Search.Placeholder")
    }
    
    private func setupSubviews() {
        view.addSubview(infoView)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        infoView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        infoView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        infoView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        infoView.changedUnit = { [weak self] newUnit in
            self?.history.forEach { $0.unit = newUnit }
            self?.reloadData(self?.history ?? [])
        }

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: infoView.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.register(HistoryCell.self, forCellReuseIdentifier: Constants.cellId)
    }
    
    @objc private func requestWithLocation() {
        presenter.requestWithLocation()
    }
    
    func reloadData(_ history: [WeatherItem]) {
        self.history = history
        infoView.configure(history.first)
        tableView.reloadData()
    }
    
    func reloadData(_ newItem: WeatherItem) {
        history.insert(newItem, at: 0)
        infoView.configure(history.first)
        tableView.reloadData()
    }
    
    func showAlert() {
        
    }
}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId) as? HistoryCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.configure(history[indexPath.row])
        return cell
    }
}

extension WeatherViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        presenter.requestWith(cityName: text)
    }
}
