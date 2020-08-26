//
//  Router.swift
//  Pokemons Info Test
//
//  Created by Vadym on 26.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import UIKit

protocol RouterMain {
    var navigationController: UINavigationController? { get set }
    var assemblyBuilder: AssemblyBuilderProtocol? { get set }
}

protocol RouterProtocol: RouterMain {
    func initialVC()
    func showDetail(model: Pokemon?)
}

class Router: RouterProtocol {
    var navigationController: UINavigationController?
    var assemblyBuilder: AssemblyBuilderProtocol?
    
    init (navConroller: UINavigationController, assemblyBuilder: AssemblyBuilderProtocol) {
        self.navigationController = navConroller
        self.assemblyBuilder = assemblyBuilder
    }
    
    func initialVC() {
        if let navConroller = navigationController {
            guard let mainVC = assemblyBuilder?.createMainModuleMethod(router: self) else { return }
            navConroller.viewControllers = [mainVC]
        }
    }
    
    func showDetail(model: Pokemon?) {
        if let navConroller = navigationController {
            guard let detailVC = assemblyBuilder?.createDetailModuleMethod(model: model) else { return }
            navConroller.pushViewController(detailVC, animated: true)
        }
    }
}

