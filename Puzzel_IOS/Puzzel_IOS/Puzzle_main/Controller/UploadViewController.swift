//
//  UploadViewController.swift
//  Assignment2
//
//  Created by user276180 on 11/12/25.
//


import UIKit

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    

    @IBOutlet var birdImageView: UIImageView!
    
    @IBOutlet var nameField: UITextField!
    
    @IBOutlet var licenseField: UITextField!
    @IBOutlet var photographerField: UITextField!
    
    @IBOutlet var pickImageButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var birdLinkField: UITextField!
    @IBOutlet var photographerLinkField: UITextField!
    private var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    //Image Picker
    @IBAction func pickImageTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    // Called when the user finishes selecting an image
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            birdImageView.image = image
        }
    }
    //Check if bird name already exists on server
    func checkIfBirdExists(name: String, completion: @escaping (Bool) -> Void) {
        BirdleAPI.shared.fetchBirdNameList { birdNames in
            
            let exists = birdNames.contains { $0.lowercased() == name.lowercased() }
            completion(exists)
        }
    }
    private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    // MARK: - Upload Action
    @IBAction func uploadTapped(_ sender: UIButton) {
        guard let image = selectedImage else {
            showAlert(title: "Missing Fields", message: "Please complete all fields.")
            print("Error: Missing image. Please select an image first.")
            return
        }
        // Validate all text fields
        guard let name = nameField.text, !name.isEmpty,
              let photographer = photographerField.text, !photographer.isEmpty,
              let license = licenseField.text, !license.isEmpty,
              let pLink = photographerLinkField.text, !pLink.isEmpty,
              let bLink = birdLinkField.text, !bLink.isEmpty else {
            showAlert(title: "Missing Fields", message: "Please complete all fields.")
            return
        }
        // Check for duplicate bird name before uploading
        checkIfBirdExists(name: name) { [weak self] exists in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if exists {
                    self.showAlert(title: "Duplicate Bird", message: "This bird name already exists on the server.")
                    print("Duplicate bird: This bird name already exists on the server.")
                    
                    return
                } else {
                    self.uploadButton.isEnabled = false
                    self.uploadButton.setTitle("Uploading...", for: .normal)
                    // Upload to server via API
                    BirdleAPI.shared.uploadBird(
                        name: name,
                        image: image,
                        photographer: photographer,
                        license: license,
                        photographerLink: pLink,
                        birdLink: bLink
                    ) { success in
                        DispatchQueue.main.async {
                            self.uploadButton.isEnabled = true
                            self.uploadButton.setTitle("Upload", for: .normal)
                            // Show success/failure popup
                            self.showAlert(
                                                            title: success ? "Success" : "Failed",
                                                            message: success ? "Upload successful" : "Upload failed!")
                            
                        }
                    }
                }
            }
        }
    }

    }

    // MARK: - UI Styling
   

