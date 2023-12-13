//
//  ImageViewController.swift
//  Final_Assignment
//
//  Created by user235429 on 12/9/23.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var images: [ImageModel] = []
    var breedName: String?
    var imageIndex: Int = 0
    var slideshowTimer: Timer?
    var isSlideshowRunning: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if there are images to display
        guard !images.isEmpty else {
            print("No images to display.")
            return
        }
        title = breedName ?? "Unknown Breed"
        setupSlideshowGesture()
        // Start displaying images
        displayImages()
    }

    func setupSlideshowGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSlideshow))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }

    @objc func toggleSlideshow() {
        isSlideshowRunning.toggle()
        if isSlideshowRunning {
            displayImages()
        } else {
            slideshowTimer?.invalidate()
            slideshowTimer = nil
        }
    }

    func displayImages() {
        guard isSlideshowRunning else {
            print("Slideshow stopped.")
            return
        }

        let imageURLString = images[imageIndex].url
        if let imageURL = URL(string: imageURLString) {
            downloadImage(from: imageURL)
            // Schedule the next image after a delay (you can customize the delay)
            slideshowTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                self.imageIndex = (self.imageIndex + 1) % self.images.count
                self.displayImages()
            }
        }
    }

    func downloadImage(from url: URL) {
        print("Downloading image from: \(url.absoluteString)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }

            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            } else {
                print("No image data or unable to create UIImage from data.")
            }
        }.resume()
    }
}
