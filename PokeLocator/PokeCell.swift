//
//  PokeCell.swift
//  PokeLocator
//
//  Created by Pasha Bahadori on 9/18/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit

class PokeCell: UICollectionViewCell {
    
    @IBOutlet weak var pokemonImg: UIImageView!
    
    @IBOutlet weak var pokemonName: UILabel!
    
    var pokemon1: Pokemon!
    
    //ROUNDING THE CELL'S BORDER
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 5.0
    }
    
    func configureCell(_ pokemon: Pokemon) {
        self.pokemon1 = pokemon
        
        pokemonName.text = self.pokemon1.pokemonName.capitalized
        pokemonImg.image = UIImage(named: "\(self.pokemon1.pokedexID)")
        
    }
    
  
    
}
