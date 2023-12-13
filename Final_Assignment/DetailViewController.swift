//
//  DetailViewController.swift
//  Final_Assignment
//
//  Created by user235429 on 12/6/23.
//

// DetailViewController.swift

import UIKit

class DetailViewController: UIViewController {

    var selectedBreedId: Int?
    var selectedBreedName: String?
    var images: [ImageModel] = []

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var lifeSpanLabel: UILabel!
    @IBOutlet weak var bredForLabel: UILabel!
    @IBOutlet weak var breedGroupLabel: UILabel!
    @IBOutlet weak var tempermantLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let selectedBreedId = selectedBreedId {
            // Fetch breed details
            fetchBreedDetails(breedId: selectedBreedId)
        }
    }

    func fetchBreedDetails(breedId: Int) {
        NetworkManager.shared.fetchBreedDetails(breedId: breedId) { [weak self] dogDetails in
            if let dogDetails = dogDetails {
                DispatchQueue.main.async {
                    self?.updateUIWithBreedDetails(dogDetails)
                }
            } else {
                print("Error fetching breed details.")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage", let imageViewController = segue.destination as? ImageViewController {
            imageViewController.images = images
            imageViewController.breedName = selectedBreedName
        }
    }

    func updateUIWithBreedDetails(_ dogDetails: DogModel) {
        nameLabel.text = "Name: \(dogDetails.name)"
        selectedBreedName = dogDetails.name
        if let weight = dogDetails.weight?["metric"] {
            weightLabel.text = "Weight: \(weight) kg"
        } else {
            weightLabel.text = "Weight not available"
        }

        if let height = dogDetails.height?["metric"] {
            heightLabel.text = "Height: \(height) cm"
        } else {
            heightLabel.text = "Height not available"
        }

        lifeSpanLabel.text = "Life Span: \(dogDetails.lifeSpan ?? "Not available")"
        bredForLabel.text = "Bred For: \(dogDetails.bredFor ?? "Not available")"
        breedGroupLabel.text = "Breed Group: \(dogDetails.breedGroup ?? "Not available")"
        tempermantLabel.text = "Temperament: \(dogDetails.temperament ?? "Not available")"
        
        if let origin = dogDetails.origin, !origin.isEmpty {
            originLabel.text = "Origin: \(origin)"
        } else {
            originLabel.text = "Origin: Not available"
        }
    }
}
