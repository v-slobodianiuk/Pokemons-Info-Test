//
//  PokemonDetailsViewController.swift
//  Pokemons Info Test
//
//  Created by Vadym on 25.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import UIKit

class PokemonDetailsViewController: UIViewController {
    
    var presenter: PokemonDetailsPresenterProtocol!
    
    private let placeholderImage = UIImage.drawCircle(diameter: UIScreen.main.bounds.width, color: .lightGray)
    
    private lazy var pokemonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var pokemonName: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(pokemonImage)
        view.addSubview(pokemonName)
        view.addSubview(scrollView)
        scrollView.addSubview(descriptionStack)
        
        DispatchQueue.global().async {
            self.presenter.getInfo()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            pokemonImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pokemonImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            pokemonImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            pokemonImage.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4),
            
            pokemonName.topAnchor.constraint(equalTo: pokemonImage.bottomAnchor, constant: 10),
            pokemonName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pokemonName.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1),
            
            scrollView.topAnchor.constraint(equalTo: pokemonName.bottomAnchor, constant: 15),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            descriptionStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            descriptionStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            descriptionStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            descriptionStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            descriptionStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
}
extension PokemonDetailsViewController {
    private func setupDescription(abilities: [Abilities]) {
        var item = 0
        for ability in abilities {
            let label = UILabel()
            self.descriptionStack.addArrangedSubview(label)
            label.font = .preferredFont(forTextStyle: .headline)
            label.sizeToFit()
            label.text = "Ability: \(ability.ability.name.capitalized)"
            
            let description = UILabel()
            self.descriptionStack.addArrangedSubview(description)
            description.numberOfLines = 0
            description.sizeToFit()
            description.text = presenter.abilityDescription(item: item)
            
            item += 1
        }
    }
}

extension PokemonDetailsViewController: PokemonDetailsViewProtocol {
    func setImage(id: Int) {
        pokemonImage.sdWebImage(id: id, placeholderImage: placeholderImage)
    }
    
    func abilitiesData(abilities: [Abilities]) {
        setupDescription(abilities: abilities)
    }
    
    func setLabel(string: String?) {
        pokemonName.text = string
    }
}
