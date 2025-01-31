//
//  NetworkController.swift
//  PokemonSwiftUI
//
//  Created by Wylan L Neely on 1/24/25.
//

import UIKit
import Combine

class NetworkController {
    
    enum HTTPMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    static func performRequest(for url: URL,
                               httpMethod: HTTPMethod,
                               urlParameters: [String: String]? = nil,
                               headers: [String: String]? = nil,
                               body: Data? = nil) async throws -> Data {
        let requestURL = self.url(byAdding: urlParameters, to: url)
        var request = URLRequest(url: requestURL)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        request.timeoutInterval = 50
        request.allHTTPHeaderFields = headers

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }

    static func url(byAdding parameters: [String: String]?, to url: URL) -> URL {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = parameters?.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components?.url else { fatalError("URL Optional is nil") }
        return url
    }
    
    
    static func fetchPokemon(_ searchTerm: String) async throws -> Pokemon? {
           guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/") else {
               throw URLError(.badURL)
           }
           let pokeURL = url.appendingPathComponent(searchTerm.lowercased())
        
           let data = try await performRequest(for: pokeURL, httpMethod: .get)
           
          //test this area
           if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
               return Pokemon(pokemonDictionary: json)
           }
           
           throw URLError(.cannotParseResponse)
       }
    
    static func downloadImage(from url: URL) -> AnyPublisher<UIImage, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, _ in
                guard let image = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }
                return image
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    
}
