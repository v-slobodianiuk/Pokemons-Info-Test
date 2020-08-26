//
//  PokemonCell.swift
//  Pokemons Info Test
//
//  Created by Vadym on 25.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import UIKit

class PokemonCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()

        self.imageView?.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        self.imageView?.contentMode = .scaleAspectFit
        self.textLabel?.frame = CGRect(x: 60, y:10, width: self.frame.width - 45, height: 20)
        self.detailTextLabel?.frame = CGRect(x: 60, y: 30, width: self.frame.width - 45, height: 15)
        self.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
    }
}
