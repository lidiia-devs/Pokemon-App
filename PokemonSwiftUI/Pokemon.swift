//
//  Pokemon.swift
//  PokemonSwiftUI
//
//  Created by Wylan L Neely on 1/24/25.
//

import Foundation
import SwiftUI

struct Pokemon: Identifiable, Codable {
    let name: String
    let id: Int // Identifiable Protocol needs an id or UUID
    let types: [String]
    let imageURLs: [URL]
    let abilities: [String]
    
    init(name: String, id: Int, types: [String], imageURLs: [URL], abilities: [String]) {
        self.name = name
        self.id = id
        self.types = types
        self.imageURLs = imageURLs
        self.abilities = abilities
    }
}

extension Pokemon {
    
    private static let kName = "name"
    private static let kId = "id"
    private static let kAbilities = "abilities"
    private static let kTypes = "types"
    private static let KSprites = "sprites"
    
    init?(pokemonDictionary: [String: Any]) {
          guard let name = pokemonDictionary[Pokemon.kName] as? String,
                
          let id = pokemonDictionary[Pokemon.kId] as? Int,
                
          let abilitityDictionaries = pokemonDictionary[Pokemon.kAbilities] as? [[String: Any]],
                
         //Go over the differences between Any and AnyObject
          let typesDictionary = pokemonDictionary[Pokemon.kTypes] as? [[String: Any]]  else {return nil}
        
        var urls = [URL]()
        
        if let spriteUrlArray = pokemonDictionary[Pokemon.KSprites] as? [String:Any] {
            for sprite in spriteUrlArray {
                if let urlString = sprite.value as? String {
                    if let url = URL(string: urlString) {
                        urls.append(url)
                    }
                }
                
            }
        }
        
        var abilities = [String]()
        
        for abilityDictionary in abilitityDictionaries {
            if let ability = abilityDictionary["ability"] as? [String:Any],
               let abilityName = ability["name"] as? String {
                abilities.append(abilityName)
            }
        }
        
        var types: [String] = []

        for typeDict in typesDictionary {
            if let type = typeDict["type"] as? [String: Any],
               let name = type["name"] as? String {
                types.append(name)
            }
        }
        

        
        self.init(name:name , id: id, types: types, imageURLs: urls, abilities: abilities)
          
          
          
      }
}
