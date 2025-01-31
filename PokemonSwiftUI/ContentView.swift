//
//  ContentView.swift
//  PokemonSwiftUI
//
//  Created by Lidiia Diachkovskaia on 1/24/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var searchText = "Mew"
    @State private var pokemon: Pokemon? = nil
    
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    
    
    var body: some View {
        
        HStack{
            TextField("Search Pokemon", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .foregroundColor(Color.gray)
                .padding(.leading, 10.0)
                //.padding(.leading, 10.0)
            
            Button(action: {
                fetchPokemon(for: searchText)
                
                
            }) {
                Label("Search", systemImage: "magnifyingglass")
                    .labelStyle(.iconOnly)
                    .padding()
                    .foregroundColor(Color.gray.opacity(0.8))
                // .clipShape(Circle())
            }
            .padding(.trailing,5.0)
        }
        .background(Color.yellow.opacity(1.0))
        .cornerRadius(16)
        .padding(.horizontal, 20.0)
        .padding(.top, 10)
        
        
        
        Group{
            if isLoading { //if loading run this block of code
                ProgressView("Fetching Pokemon...")
                    .padding()
            } else if let pokemon = pokemon { //if a pokemon exists run this code
                //fun pokemonView
                PokemonView(pokemon: pokemon)
                
//                VStack{
//                    Text(pokemon.name)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
            } else if let error = errorMessage { //if there is not a pokemon
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Please Search for a Pokemon")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    //MARK: Functions
    private func fetchPokemon(for pokemonName: String) {
        guard !pokemonName.isEmpty else {
            errorMessage = "Enter Pokemon Name"
            return
        }
        
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetchPokemon = try await NetworkController.fetchPokemon(pokemonName.lowercased())
                await MainActor.run {
                    
                    pokemon = fetchPokemon
                    isLoading = false
                }
            } catch {
                    await MainActor.run {
                        errorMessage = "Error: \(error.localizedDescription)"
                        isLoading = false
                    }
                }
                
            }
            
        }
    }

struct PokemonView: View {
    let pokemon: Pokemon
    var body: some View {
        VStack {
            AsyncImage(url: pokemon.imageURLs.first) {
                phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200, maxHeight: 200)
                case .failure:
                    EmptyView()
                @unknown default:
                    EmptyView()
                }
            }
            
                Text(pokemon.name)
                    .padding()
//                ForEach(pokemon.types, id:\.self) {
//                    poketype in
//                    Text(poketype)
//                        .padding(.trailing, 20)
//                }
                
                
            }
            List{
                Section {
                    ForEach(pokemon.abilities, id:\.self) {
                        poketype in PokemonViewRows(pokeText: poketype)
                    }
                    //.listRowBackground(<#T##view: View?##View?#>)
                    .background(Color.yellow)
                    .cornerRadius(14)
                    //Text(pokemon.abilities.first ?? "no abilities")
                } header : {
                    Text("Abilities")
                        .font(.largeTitle)
                }
                
                Section {
                    ForEach(pokemon.abilities, id:\.self) {
                        ability in PokemonViewRows(pokeText: ability)
                    }
                    .background(Color.yellow)
                    .cornerRadius(14)
                    //Text(pokemon.abilities.first ?? "no abilities")
                } header : {
                    Text("Types")
                }
            }
            
            
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
    }
    
}

struct PokemonViewRows: View {
    let pokeText: String
    
    var body: some View {
        Text(pokeText)
            .font(.title)
        
    }
}

#Preview {
    ContentView()
}

