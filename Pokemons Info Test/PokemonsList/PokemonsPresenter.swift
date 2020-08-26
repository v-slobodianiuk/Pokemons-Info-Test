//
//  PokemonsPresenter.swift
//  Pokemons Info Test
//
//  Created by Vadym on 25.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import Foundation

protocol PokemonsViewProtocol: class {
    func reloadTable()
    func startTask()
    func taskDone()
    func apiError(error: String?)
}

protocol PokemonsPresenterProtocol: class {
    
    init(viewController: PokemonsViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol)

    var title: String {get}
    var pokemonCellReuseIdentifier: String {get}
    
    func numberOfRowsInSection() -> Int
    func pokemonId(indexPath: Int) -> Int?
    func pokemonName(indexPath: Int) -> String?
    func abilitiesString(indexPath: Int) -> String?
    func startTask()
    func search(string: String?)
    func cancellSearch()
    func sendPokemonInfo(indexpath: Int)
    func loadOnScroll(indexpath: Int)
}

class PokemonsPresenter: PokemonsPresenterProtocol {
    
    private weak var view: PokemonsViewProtocol?
    private var networkService: NetworkServiceProtocol?
    private var router: RouterProtocol?
    private var pokemons: Pokemons?
    private var pokemon: [Pokemon]?
    let title = "Pokemons"
    let pokemonCellReuseIdentifier = "Pokemon Cell"
    private lazy var isLoadingData = false
    private lazy var isSearching = false
    private lazy var queryItems = [URLQueryItem] ()
    
    private let concurrentQueue = DispatchQueue(label: "Data Queue", attributes: .concurrent)
    private let myGroup = DispatchGroup()
    
    required init(viewController: PokemonsViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.view = viewController
        self.networkService = networkService
        self.router = router
        pokemon = []
    }
    
    func startTask() {
        let start = CFAbsoluteTimeGetCurrent()
        concurrentQueue.async(group: myGroup) {
            self.view?.startTask()
            //print("startTask", Thread.current)
        }
        myGroup.wait()
        
        concurrentQueue.async(group: myGroup) {
            //print("getPokemonsList", Thread.current)
            self.getPokemonsList()
        }
        myGroup.wait()
        
        concurrentQueue.async(group: myGroup) {
            //print("getPokemonInfo", Thread.current)
            self.getPokemonInfo()
        }
        
        myGroup.notify(queue: concurrentQueue) {
            //print("taskDone", Thread.current)
            let finish = CFAbsoluteTimeGetCurrent()
            let timeElapsed = finish - start
            print("Time for Data Group is \(timeElapsed) seconds. \(self.pokemon?.count ?? 0) objects loaded.")
            
            self.view?.reloadTable()
            self.view?.taskDone()
            //self.isLoadingData = false
        }
    }
    
    func getPokemonsList() {
        guard !isLoadingData else { return }
        isLoadingData.toggle()
        queryItems.removeAll()
        
        if let urlString = pokemons?.next {
            let nextPockemonsUrl = URLComponents(string: urlString)!
            queryItems.append(URLQueryItem(name: "offset", value: nextPockemonsUrl.queryItems?.first?.value))
            queryItems.append(URLQueryItem(name: "limit", value: nextPockemonsUrl.queryItems?.last?.value))
        }
        
        let url = self.networkService?.urlComponents(urlPath: "pokemon", queryItems: queryItems)
        
        myGroup.enter()
        self.getRequest(url: url!) { [weak self] (data) in
            //print("getRequest Closure", Thread.current)
            self?.pokemons = JsonServise.shared.jsonDecode(data: data)
            self?.myGroup.leave()
        }
    }
    
    func getRequest(url: URL, completion: @escaping (_ data: Data) -> Void) {
        networkService?.apiRequest(requestURL: url, requestMethod: "GET", { [weak self] (result) in
            switch result {
            case .success(let jsonData):
                guard let data = jsonData else { return }
                completion(data)
                self?.isLoadingData.toggle()
            case .failure(let error):
                self?.view?.apiError(error: error.localizedDescription)
                self?.isLoadingData.toggle()
                self?.myGroup.leave()
            }
        })
    }
    
    func getPokemonInfo() {
        guard let pokemonsList = pokemons?.results else { fatalError("Nil") }
        for pokemon in pokemonsList {
            myGroup.enter()
            if let url = URL(string: pokemon.url) {
                let requestUrl = self.networkService?.urlComponents(urlPath: "pokemon/\(url.lastPathComponent)", queryItems: nil)
                self.getRequest(url: requestUrl!) { [weak self] (data) in
                    //print("Pokemon getRequest Closure", Thread.current)
                    let unit: Pokemon? = JsonServise.shared.jsonDecode(data: data)
                    guard let pokemonData = unit else { return }
                    self?.pokemon?.append(pokemonData)
                    self?.myGroup.leave()
                }
            }
        }
    }
    
    func searchTask(name: String?) {
        let url = self.networkService?.urlComponents(urlPath: "pokemon/\(name?.lowercased() ?? "")", queryItems: nil)
        
        myGroup.enter()
        self.getRequest(url: url!) { [weak self] (data) in
            let unit: Pokemon? = JsonServise.shared.jsonDecode(data: data)
            guard let pokemonData = unit else { return }
            self?.pokemon?.append(pokemonData)
            self?.myGroup.leave()
        }
    }
    
    func search(string: String?) {
        concurrentQueue.async(group: myGroup) {
            self.isSearching = true
            self.pokemon?.removeAll()
        }
        myGroup.wait()
        
        concurrentQueue.async(group: myGroup) {
            self.view?.reloadTable()
        }
        myGroup.wait()
        
        concurrentQueue.async(group: myGroup) {
            self.view?.startTask()
        }
        myGroup.wait()
        
        concurrentQueue.async(group: myGroup) {
            self.searchTask(name: string)
        }
        
        myGroup.notify(queue: concurrentQueue) {
            self.view?.reloadTable()
            self.view?.taskDone()
        }
    }
    
    func cancellSearch() {
        isSearching.toggle()
        startTask()
    }
    
    func loadOnScroll(indexpath: Int) {
        guard let pokemon = pokemon, !isSearching else { return }
        if indexpath == pokemon.count - 1 {
            self.startTask()
        }
    }
    
    func numberOfRowsInSection() -> Int {
        pokemon?.count ?? 0
    }
    
    func pokemonId(indexPath: Int) -> Int? {
        guard let pokemon = pokemon else { return nil }
        return pokemon[indexPath].id
    }
    
    func pokemonName(indexPath: Int) -> String? {
        guard let pokemon = pokemon else { return nil }
        return pokemon[indexPath].name.capitalized
    }
    
    func abilitiesString(indexPath: Int) -> String? {
        guard let pokemon = pokemon else { return nil }
        return pokemon[indexPath].abilities.map{$0.ability.name.capitalized}.joined(separator: ", ")
    }
    
    func sendPokemonInfo(indexpath: Int) {
        guard let pokemon = pokemon else { return }
        router?.showDetail(model: pokemon[indexpath])
    }
}
