//
//  NetworkManager.swift
//  Final_Assignment
//
//  Created by user235429 on 12/6/23.
//


import Foundation

enum NetworkError: Error {
    case invalidURL
    case dataTaskError(Error)
    case invalidResponse
    case noData
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    private let apiKey = "live_bisvmKYc7Iv44yahTNrJunH4vJYmeNOSF3GIggFJW8pscdIE2N1jN690vMc9ldiY"

    func fetchAllDogs(completion: @escaping ([DogModel]?) -> Void) {
            var allDogs: [DogModel] = []
            var currentPage = 0

            func fetchPage() {
                var urlComponents = URLComponents(string: "https://api.thedogapi.com/v1/breeds")!
                urlComponents.queryItems = [
                    URLQueryItem(name: "limit", value: "200"),
                    URLQueryItem(name: "page", value: "\(currentPage)"),
                ]

                var request = URLRequest(url: urlComponents.url!)
                request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")

                URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(nil)
                        return
                    }

                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let pageDogs = try decoder.decode([DogModel].self, from: data)
                        allDogs.append(contentsOf: pageDogs)

                        if !pageDogs.isEmpty {
                            currentPage += 1
                            fetchPage()
                        } else {
                            completion(allDogs)
                        }
                    } catch {
                        print("Error decoding dog breeds: \(error)")
                        completion(nil)
                    }
                }.resume()
            }

            fetchPage()
        }


    func fetchBreedDetails(breedId: Int, completion: @escaping (DogModel?) -> Void) {
        let url = URL(string: "https://api.thedogapi.com/v1/breeds/\(breedId)")!
        var request = URLRequest(url: url)
        //request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                            completion(nil)
                            return
                        }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let dogDetails = try decoder.decode(DogModel.self, from: data)
                print("Dog Details JSON: \(String(data: data, encoding: .utf8) ?? "")")
                completion(dogDetails)
            } catch {
                print("Error decoding breed details: \(error)")
                completion(nil)
            }

        }.resume()
    }
    
    func fetchImageForBreed(breedId: Int, completion: @escaping (Result<[ImageModel], NetworkError>) -> Void) {
        let imageUrlString = "https://api.thedogapi.com/v1/images/search?limit=2&breed_id=\(breedId)"
        
        guard let url = URL(string: imageUrlString) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        // Uncomment the following line if you need to include the API key
        // request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.dataTaskError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let images = try decoder.decode([ImageModel].self, from: data)
                print("API Response:", images)
                completion(.success(images))
            } catch {
                print("Error decoding images: \(error)")
                completion(.failure(.invalidResponse))
            }
        }.resume()
    }

}

