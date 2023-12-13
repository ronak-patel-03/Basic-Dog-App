//
//  DogModel.swift
//  Final_Assignment
//
//  Created by user235429 on 12/6/23.
//

import Foundation

struct DogModel: Codable {
    let id: Int
    let name: String
    var weight: [String: String]?
    var height: [String: String]?
    var lifeSpan: String?
    var bredFor: String?
    var breedGroup: String?
    var temperament: String?
    var origin: String?
    var reference_image_id: String?
}

