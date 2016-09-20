//
//  Pokemon.swift
//  PokeLocator
//
//  Created by Pasha Bahadori on 9/19/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit
import Foundation

class Pokemon {

    //Name and number
    fileprivate var _pokemonName: String!
    fileprivate var _pokedexID: Int!
    
    
    var pokemonName: String {
        return _pokemonName
    }
    
    var pokedexID: Int {
        return _pokedexID
    }
    
    
    init(pokemonName: String, pokedexID: Int) {
        self._pokemonName = pokemonName
        self._pokedexID = pokedexID
    }
    
}
