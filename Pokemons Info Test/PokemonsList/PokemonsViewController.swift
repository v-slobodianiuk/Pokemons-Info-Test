//
//  ViewController.swift
//  Pokemons Info Test
//
//  Created by Vadym on 25.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import UIKit

class PokemonsViewController: UIViewController {
    
    var presenter: PokemonsPresenterProtocol!
    let placeolderImage = UIImage.drawCircle(diameter: 40, color: .lightGray)
    lazy var searchController = UISearchController(searchResultsController: nil)
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            indicator.style = .large
        } else {
            indicator.style = .medium
        }
        indicator.center = CGPoint(x: UIScreen.main.bounds.maxX / 2, y: UIScreen.main.bounds.maxY / 2)
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
            self.presenter.startTask()
        }
        
        self.view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.title = presenter.title
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        setupTableView()
        setupSearchBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setContraints()
    }
    
    private func setContraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension PokemonsViewController {
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: presenter.pokemonCellReuseIdentifier)
    }
    
    private func setupSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pokemon by Name"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

extension PokemonsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard searchController.searchBar.text != "" else { return }
        presenter.search(string: searchController.searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.cancellSearch()
    }
}

extension PokemonsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.sendPokemonInfo(indexpath: indexPath.row)
    }
}

extension PokemonsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = PokemonCell(style: .subtitle, reuseIdentifier: presenter.pokemonCellReuseIdentifier)
        cell.textLabel?.text = presenter.pokemonName(indexPath: indexPath.row)
        cell.detailTextLabel?.text = presenter.abilitiesString(indexPath: indexPath.row)
        if let id = presenter.pokemonId(indexPath: indexPath.row) {
            cell.imageView?.sdWebImage(id: id, placeholderImage: placeolderImage)
        }
        
        presenter.loadOnScroll(indexpath: indexPath.row)
        return cell
    }
}

extension PokemonsViewController: PokemonsViewProtocol {
    func apiError(error: String?) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func taskDone() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func startTask() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
