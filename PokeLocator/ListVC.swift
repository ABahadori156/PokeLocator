//
//  ListVC.swift
//  PokeLocator
//
//  Created by Pasha Bahadori on 9/18/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

protocol PokeSightingDelegate {
    func spotRandomPokemon()
}


class ListVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
//    var pokemonArray = pokemon
//    var filteredPokemonArray = [String]()
    
    var pokemonAno = [Pokemon]()
    var filteredPokemonAno = [Pokemon]()
    var inSearchMode = false
    var mainVC = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        parsePokemonCSV()

        
       
    }

    func parsePokemonCSV() {
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
        
        do {
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            
            for row in rows {
                let pokeID = Int(row["id"]!)!
                let name = row["identifier"]!
                
                print(pokeID)
                let poke = Pokemon(pokemonName: name, pokedexID: pokeID)
                pokemonAno.append(poke)
            }
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    
    
    //SEARCH BAR METHOD - To end the keyboard when we're finished searching for Pokemon
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    //This func makes the filteredPokemonArray the datasource of the collectionView when we begin searching
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        inSearchMode = true
//        collectionView.reloadData()
//    }
    
    //This function makes the pokemonArray the datasource when the cancel button of the search bar is tapped
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        inSearchMode = false
        collectionView.reloadData()
    }
    
//    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
//        if !inSearchMode {
//            inSearchMode = true
//            collectionView.reloadData()
//        }
//        searchBar.resignFirstResponder()
//    }
    

 
    
    //SEARCH BAR METHOD
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//       filteredPokemonArray = pokemonArray.filter({ (text) -> Bool in
//        let tmp: NSString = text as NSString
//        let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
//        return range.location != NSNotFound
//       })
//        if(filteredPokemonAno.count == 0) {
//            inSearchMode = false
//        } else {
//            inSearchMode = true
//        }
//        self.collectionView.reloadData()
//    }
    
    //SEARCH BAR METHOD
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            collectionView.reloadData()
            view.endEditing(true)
        } else {
            inSearchMode = true
            
            let lower = searchBar.text!.lowercased()
            
            filteredPokemonAno = pokemonAno.filter({$0.pokemonName.range(of: lower) != nil})
            
            collectionView.reloadData()
        }
    }
    
    
    
    
    
    //I have an array of strings, so when I start typing characters in the search bar, I want only those strings in the array to come up that have the characters in the search bar
    // When I select a pokecell, I want it to place that Pokemon on the map and save it to Firebase on that location
    //How to call a method in a viewontroller from another viewController
    
    //SIGHTING FUNCTION - a function to save a sighting of a pokemon and it's location to the database
//    func createSighting(forLocation location: CLLocation, withPokemon pokeId: Int) {
//        //Whenever you sight a pokemon and call this function, it will call geoFire base and set a location for that sighting data
//        //We pass in the location and pass in the key that references that location
//        geoFire.setLocation(location, forKey: "\(pokeId)")
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PokeCell {
        
        let poke: Pokemon!
        
        if inSearchMode == true {
            poke = filteredPokemonAno[indexPath.row]
            cell.configureCell(poke)
            print("************** HERE IS THE POKEMONIMG \(cell.pokemonImg.image)*************")
            print("************** HERE IS THE POKEMONNAME \(cell.pokemonName.text)*************")
        } else {
            poke = pokemonAno[indexPath.row]
            cell.configureCell(poke)
            print("************** HERE IS THE POKEMONIMG \(cell.pokemonImg.image)*************")
            print("************** HERE IS THE POKEMONNAME \(cell.pokemonName.text)*************")
        }
        
        
        return cell
        
        } else {
            return UICollectionViewCell()
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        print((pokemonAno.first?.pokedexID)!)
       
    }
   
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredPokemonAno.count
        }
        
        return pokemonAno.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 105)
    }

}


/*  
 
 @IBAction func spotRandomPokemon(_ sender: UIButton) {
 
 let centerLoc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
 
 let random = arc4random_uniform(151) + 1    //This is a range between 1-150
 
 createSighting(forLocation: centerLoc, withPokemon: Int(random))
 }
 
 */
