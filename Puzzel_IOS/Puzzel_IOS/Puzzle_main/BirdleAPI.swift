
//  BirdleAPI.swift
//  Assignment2
//
//  Created by user276180 on 11/20/25.
//
import Foundation
import UIKit
class BirdleAPI{
    
    static let shared = BirdleAPI()
    private let linkBase = "https://easterbilby.net/birdle/api.php"
    private init(){}
    
    // Fetches default current puzzle directly from the base URL
    func getPuzzlesToday(completion: @escaping (BirdInfo?) -> Void ){
        guard let url = URL(string: linkBase) else {
                    print("Invalid URL")
                    return completion(nil)
                }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) {
            data, response, error in if let error = error {
                print("Error network", error)
                return completion(nil)
            }
            guard let data = data else{
                print("There's no data")
                return completion(nil)
            }
            do {
                // Decode JSON data into BirdInfo model
                let puzzle = try JSONDecoder().decode(BirdInfo.self, from: data)
                completion(puzzle)
            }
            catch {
                print("Fail decoding JSON", error)
                completion(nil)
            }
        }.resume()
    }
    // Calculate daily puzzle ID based on current day and total puzzles
    func getDailyPuzzleID(total: Int) -> Int {
        let days = Int(Date().timeIntervalSince1970 / 86400)
        return days % total
    }
    // Fetch the daily puzzle by first getting the full list of birds
    func getDailyPuzzle(completion: @escaping (BirdInfo?) -> Void) {

           // Get full list to know total puzzles
           fetchBirdNameList { birds in
               if birds.isEmpty {
                   completion(nil)
                   return
               }

               //  Calculate daily ID
               let id = self.getDailyPuzzleID(total: birds.count)

               // Download puzzle by ID
               self.getPuzzleByID(id: id) { puzzle in
                   completion(puzzle)
               }
           }
       }
    //Fetch a specific puzzle by its ID from the server
    func getPuzzleByID(id: Int, completion: @escaping (BirdInfo?) -> Void){
        let urlString = "\(linkBase)?action=download&id=\(id)"
        guard let url = URL(string: urlString) else{
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url){
            data, response, error in guard let data = data else {
                completion(nil)
                return
            }
            if let error = try? JSONDecoder().decode([String: String].self, from: data), error["result"] == "error" {
                completion(nil)
                return
            }
            let puzzle = try? JSONDecoder().decode(BirdInfo.self, from: data)
            completion(puzzle)
        }.resume()
        
    }
    // Fetch list of bird names from the server
    func fetchBirdNameList(completion: @escaping ([String]) -> Void) {

            let urlString = "\(linkBase)?action=list"
            guard let url = URL(string: urlString) else {
                completion([])
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { completion([]); return }

                let list = try? JSONDecoder().decode(BirdList.self, from: data)
                completion(list?.birds ?? [])
            }.resume()
        }

        //Upload images
        func uploadBird(
            name: String,
            image: UIImage,
            photographer: String,
            license: String,
            photographerLink: String,
            birdLink: String,
            completion: @escaping (Bool) -> Void
        ) {

            let urlString = "\(linkBase)?action=upload"
            guard let url = URL(string: urlString) else { completion(false); return }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var data = Data()

            func addField(_ name: String, _ value: String) {
                data.append("--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)\r\n".data(using: .utf8)!)
            }

            // add text fields
            addField("name", name)
            addField("photographer_name", photographer)
            addField("license", license)
            addField("photographer_link", photographerLink)
            addField("birdle_link", birdLink)

            // add image
            if let jpeg = image.jpegData(compressionQuality: 0.9) {
                data.append("--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"image\"; filename=\"upload.jpg\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                data.append(jpeg)
                data.append("\r\n".data(using: .utf8)!)
            }

            data.append("--\(boundary)--\r\n".data(using: .utf8)!)

            URLSession.shared.uploadTask(with: request, from: data) { responseData, _, _ in

                guard let responseData = responseData else {
                    completion(false)
                    return
                }
                // Decode JSON
                if let dict = try? JSONDecoder().decode([String:String].self, from: responseData),
                   dict["result"] == "success" {
                    completion(true)
                } else {
                    completion(false)
                }
            }.resume()
        }
    }

