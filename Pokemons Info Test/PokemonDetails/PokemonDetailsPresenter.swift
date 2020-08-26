//
//  PokemonDetailsPresenter.swift
//  Pokemons Info Test
//
//  Created by Vadym on 25.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import Foundation

protocol PokemonDetailsViewProtocol: class {
    func setImage(id: Int)
    func setLabel(string: String?)
    func abilitiesData(abilities: [Abilities])
}

protocol PokemonDetailsPresenterProtocol: class {
    
    init(viewController: PokemonDetailsViewProtocol, networkService: NetworkServiceProtocol, model: Pokemon?)
    
    func abilityDescription(item: Int) -> String?
    func getInfo()
}

class PokemonDetailsPresenter: PokemonDetailsPresenterProtocol {
    
    private weak var view: PokemonDetailsViewProtocol?
    private var networkService: NetworkServiceProtocol?
    private var model: Pokemon?
    private var abilityModel = [AbilityModel?] ()
    
    private let concurrentQueue = DispatchQueue(label: "Description Data Queue", attributes: .concurrent)
    private let myGroup = DispatchGroup()
    
    required init(viewController: PokemonDetailsViewProtocol, networkService: NetworkServiceProtocol, model: Pokemon?) {
        self.view = viewController
        self.networkService = networkService
        self.model = model
        
        abilityModel = []
    }
    
    func getInfo() {
        guard let model = model else { return }
        
        DispatchQueue.main.async {
            self.view?.setImage(id: model.id)
            self.view?.setLabel(string: model.name.capitalized)
        }
        
        concurrentQueue.async(group: myGroup) {
            self.getAbilitiesDescription()
        }
        myGroup.wait()
        
        myGroup.notify(queue: .main) {
            self.view?.abilitiesData(abilities: model.abilities)
        }
    }
    
    func abilityDescription(item: Int) -> String? {
        for info in abilityModel[item]!.effect_entries {
            if info.language.name == "en" {
                return info.effect
            }
        }
        return nil
    }
    
    private func getRequest(url: URL, completion: @escaping (_ data: Data) -> Void) {
        networkService?.apiRequest(requestURL: url, requestMethod: "GET", { (result) in
            switch result {
            case .success(let jsonData):
                guard let data = jsonData else { return }
                completion(data)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    private func getAbilitiesDescription() {
        guard let abilities = model?.abilities else { return }
        
        for ability in abilities {
            myGroup.enter()
            if let url = URL(string: ability.ability.url) {
                let requestUrl = networkService?.urlComponents(urlPath: "ability/\(url.lastPathComponent)", queryItems: nil)
                getRequest(url: requestUrl!) { [weak self] (data) in
                    let unit: AbilityModel? = JsonServise.shared.jsonDecode(data: data)
                    self?.abilityModel.append(unit!)
                    self?.myGroup.leave()
                }
            }
        }
    }
}
