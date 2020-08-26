//
//  AbilityModel.swift
//  Pokemons Info Test
//
//  Created by Vadym on 25.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import Foundation

struct AbilityModel: Codable {
    let effect_entries: [PokemonEffectEntry]
}

struct PokemonEffectEntry: Codable {
    let effect: String
    let language: Language
}

struct Language: Codable {
    let name: String
    let url: String
}
