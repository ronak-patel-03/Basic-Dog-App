//
//  ViewController.swift
//  Final_Assignment
//
//  Created by user235429 on 12/6/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var dogs: [DogModel] = []
    var filteredDogs: [DogModel] = []

    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        definesPresentationContext = true
        searchBar.delegate = self

        fetchAllDogs()
    }

    func fetchAllDogs() {
        NetworkManager.shared.fetchAllDogs { [weak self] dogs in
            if let dogs = dogs {
                self?.dogs = dogs
                self?.filteredDogs = dogs
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            } else {
                print("Error fetching dog data.")
            }
        }
    }

    func filterDogs(with searchText: String) {
        if searchText.isEmpty {
            filteredDogs = dogs
        } else {
            filteredDogs = dogs.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }

        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterDogs(with: searchText)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDogs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DogCell", for: indexPath)
        let dog = filteredDogs[indexPath.row]
        cell.textLabel?.text = dog.name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDog = filteredDogs[indexPath.row]
        fetchImagesForBreed(breedId: selectedDog.id)
    }

    func fetchImagesForBreed(breedId: Int) {
        NetworkManager.shared.fetchImageForBreed(breedId: breedId) { [weak self] result in
            switch result {
            case .success(let images):
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: "showDetail", sender: (breedId, images))
                }
            case .failure(let error):
                print("Error fetching images: \(error)")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail", let detailVC = segue.destination as? DetailViewController, let data = sender as? (Int, [ImageModel]) {
            detailVC.selectedBreedId = data.0
            detailVC.images = data.1
        }
    }
}
