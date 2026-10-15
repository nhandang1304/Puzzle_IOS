//
//  ImageLoader.swift
//  Assignment2
//
//  Created by user276180 on 11/21/25.
//

import UIKit
/// Loads an image from a URL asynchronously
class ImageLoader {

    static let shared = ImageLoader()

    private init() {}

    func loadImage(from url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else {
            completion(nil)
            return
        }
        // Download image using URLSession
    URLSession.shared.dataTask(with: url) { data, _, error in
        // If data exists and can convert to UIImage to success
            if let data = data,
               let img = UIImage(data: data) {
                // Always update UI on main thread
                DispatchQueue.main.async {
                    completion(img)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
