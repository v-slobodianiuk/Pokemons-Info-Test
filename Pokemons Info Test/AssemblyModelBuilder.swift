//
//  ModuleBuilder.swift
//  Pokemons Info Test
//
//  Created by Vadym on 26.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import UIKit

protocol AssemblyBuilderProtocol {
    func createMainModuleMethod(router: RouterProtocol) -> UIViewController
    func createDetailModuleMethod(model: Pokemon?) -> UIViewController
}

class AssemblyModelBuilder: AssemblyBuilderProtocol {
    
    func createMainModuleMethod(router: RouterProtocol) -> UIViewController {
        
        let mainVC = PokemonsViewController()
        let networkService = NetworkService()
        let presenter = PokemonsPresenter(viewController: mainVC, networkService: networkService, router: router)
        mainVC.presenter = presenter
        return mainVC
    }
    
    func createDetailModuleMethod(model: Pokemon?) -> UIViewController {
        let detailVC = PokemonDetailsViewController()
        let networkService = NetworkService()
        let presenter = PokemonDetailsPresenter(viewController: detailVC, networkService: networkService, model: model)
        detailVC.presenter = presenter
        return detailVC
    }
}
