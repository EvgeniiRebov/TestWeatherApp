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
    func showAlert(with error: Error)
}

class WeatherViewController: UIViewController, ViewProtocol {
    private enum Constants {
        static let cellId = String.init(describing: HistoryCell.self)
    }
    
    private let presenter: PresenterProtocol
    private(set) lazy var locationSearchButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "location.north.circle"),
                               style: .plain, target: self, action: #selector(requestWithLocation))
    }()
    private(set) var infoView = InfoView()
    private(set) var tableView = UITableView()
    private(set) var searchController = UISearchController(searchResultsController: nil)
    private(set) var history: [WeatherItem] = []
    private(set) var receivedError: Error?
    
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
        navigationItem.rightBarButtonItem = locationSearchButton
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = String.localize("Search.Placeholder")
    }
    
    private func setupSubviews() {
        setupInfoView()
        setupTableView()
    }
    
    private func setupInfoView() {
        view.addSubview(infoView)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        infoView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        infoView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        infoView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        infoView.changedUnit = { [weak self]  in
            self?.history.forEach { $0.unit = UnitUserDefaults.value() }
            self?.reloadData(self?.history ?? [])
        }
    }
    
    private func setupTableView() {
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
        (navigationController ?? self).startLoading()
        presenter.requestWithLocation()
    }
    
    func reloadData(_ history: [WeatherItem]) {
        (navigationController ?? self).stopLoading()
        self.history = history
        infoView.configure(history.first)
        tableView.reloadData()
    }
    
    func reloadData(_ newItem: WeatherItem) {
        (navigationController ?? self).stopLoading()
        history.insert(newItem, at: 0)
        presenter.saveInLocal(history)
        infoView.configure(history.first)
        tableView.reloadData()
    }
    
    func showAlert(with error: Error) {
        receivedError = error
        let alertController = UIAlertController(title: String.localize("CommonError.Title"), message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in }
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
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
        (navigationController ?? self).startLoading()
        presenter.requestWith(cityName: text)
    }
}
