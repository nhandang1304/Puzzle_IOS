//
//  CompleteViewController.swift
//  Assignment2
//
//  Created by user276180 on 11/21/25.
//


import UIKit

class CompleteViewController: UIViewController{
    var tries: Int = 0
       var birdName: String = ""
       var timeTaken: Int = 0
       var photographer: String = ""
       var license: String = ""
       var infoURL: String = ""
       var birdImage: UIImage?
    
    
    
    
    @IBOutlet var birdImageView: UIImageView!
    
    @IBOutlet var moreInfo: UIButton!
    
    @IBOutlet var photographerLabel: UILabel!
    
    @IBOutlet var attemptsLabel: UILabel!
    
    @IBOutlet var licenseLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
 
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var birdNameLabel: UILabel!
    override func viewDidLoad() {
           super.viewDidLoad()
           setupUI()
           
       }

       
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let resultText = """
        Birdle Result
        Bird: \(birdName)
        Attempts: \(tries)
        Time: \(timeTaken)s
        Photographer: \(photographer)
        License: \(license)

        More info: \(infoURL)
        """

        let activityVC = UIActivityViewController(activityItems: [resultText], applicationActivities: nil)

        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }

        present(activityVC, animated: true, completion: nil)
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground

        //Bird Image Style
        birdImageView.image = birdImage
        birdImageView.layer.cornerRadius = 14
        birdImageView.clipsToBounds = true
        birdImageView.layer.borderWidth = 3
        birdImageView.layer.borderColor = UIColor.systemGray5.cgColor

        //Title / Labels
        birdNameLabel.font = .boldSystemFont(ofSize: 24)
        birdNameLabel.textColor = .label
        birdNameLabel.text = "🐦 \(birdName)"

        attemptsLabel.font = .systemFont(ofSize: 17, weight: .medium)
        timeLabel.font = .systemFont(ofSize: 17, weight: .medium)
        photographerLabel.font = .systemFont(ofSize: 15)
        photographerLabel.textColor = .secondaryLabel
        licenseLabel.font = .systemFont(ofSize: 15)
        licenseLabel.textColor = .secondaryLabel

        attemptsLabel.text = "Attempts: \(tries)"
        timeLabel.text = "Time: \(timeTaken) seconds"
        photographerLabel.text = "📸 Photographer: \(photographer)"
        licenseLabel.text = "License: \(license)"

        // More Info Button
        moreInfo.setTitle("Learn More →", for: .normal)
        moreInfo.backgroundColor = UIColor.systemBlue
        moreInfo.tintColor = .white
        moreInfo.layer.cornerRadius = 10
        moreInfo.titleLabel?.font = .boldSystemFont(ofSize: 18)
        moreInfo.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

        // Add subtle shadow for depth
        moreInfo.layer.shadowColor = UIColor.black.cgColor
        moreInfo.layer.shadowOpacity = 0.2
        moreInfo.layer.shadowRadius = 6
        moreInfo.layer.shadowOffset = CGSize(width: 0, height: 3)

        moreInfo.addTarget(self, action: #selector(moreInfoPressed), for: .touchUpInside)
    }


    @objc func moreInfoPressed() {
        guard let url = URL(string: infoURL), UIApplication.shared.canOpenURL(url) else {
            let alert = UIAlertController(title: "Invalid URL",
                                          message: "Cannot open the link.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        UIApplication.shared.open(url)
    }
   }

