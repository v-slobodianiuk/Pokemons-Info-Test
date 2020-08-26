//
//  PokemonsModel.swift
//  Pokemons Info Test
//
//  Created by Vadym on 25.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import Foundation

struct Pokemons: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonsList]
}

struct PokemonsList: Codable {
    let name: String
    let url: String
}

struct Pokemon: Codable {
    let abilities: [Abilities]
    let name: String
    let id: Int
}

struct Abilities: Codable {
    let ability: Ability
}

struct Ability: Codable {
    let name: String
    let url: String
}
