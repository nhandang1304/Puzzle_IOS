//
//  PuzzleViewController.swift
//  Assignment2
//
//  Created by user276180 on 11/12/25.
//



import UIKit
import CoreData
class PuzzleViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var resultButton: UIButton!
    @IBOutlet var timeCount: UILabel!
    @IBOutlet var birdImageView: UIImageView!
    @IBOutlet var startPuzzle: UIButton!
    @IBOutlet var guessTextField: UITextField!
    @IBOutlet var titlePuzzle: UILabel!
    
    
    @IBOutlet var historyButton: UIButton!
    //  Testing:
    //private var birdName: String = "Silver"
    //private var imageID: String = "0008"
    
    
        private var puzzle: BirdInfo!
        private var currentImageIndex = 0
        private let maxAttempts = 5
        private var attempts = 0
        
        private var timer: Timer?
        private var seconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customUI()
       
        guessTextField.delegate = self
        startPuzzle.addTarget(self, action: #selector(submitGuess), for: .touchUpInside)
        
        // Hide the result button at the start
        resultButton.isHidden = true
                resultButton.alpha = 0
                resultButton.setTitle("View Result", for: .normal)
        // Fetch puzzle from API
        loadPuzzle()
    }
    
    // Save Game History to Core Data
    func saveHistory(finalImage: UIImage, birdName: String, infoURL: String?, timeTaken: Double, attemptsCount: Int, isSuccess: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        // Create a new Core Data record
        let entity = NSEntityDescription.entity(forEntityName: "Assignment2", in: context)!
        let newRecord = NSManagedObject(entity: entity, insertInto: context)

        newRecord.setValue(birdName, forKey: "birdName")
        newRecord.setValue(Date(), forKey: "completedDate")
        newRecord.setValue(timeTaken, forKey: "timeTaken")
        newRecord.setValue(attemptsCount, forKey: "attemptsCount")
        newRecord.setValue(isSuccess, forKey: "isSuccess")
        newRecord.setValue(infoURL, forKey: "infoURL")
        // Save final image as PNG data
        if let imageData = finalImage.pngData() {
            newRecord.setValue(imageData, forKey: "imageData")
        }

        do {
            try context.save()
            print("Saved history successfully!")
        } catch {
            print("Failed saving history: \(error)")
        }
    }
    //Load Puzzle From API
    func loadPuzzle(){
        BirdleAPI.shared.getDailyPuzzle { [weak self] birdInfo in
               guard let self = self, let birdInfo = birdInfo else {
                   print("Fail fetch puzzle")
                   return
               }
            DispatchQueue.main.async {
                // Reset puzzle state
                self.puzzle = birdInfo
                self.currentImageIndex = 0
                self.attempts = 0
                self.seconds = 0
                self.timeCount.text = "00:00:00"
                self.guessTextField.isEnabled = true
                self.startPuzzle.isEnabled = true
                self.titlePuzzle.text = "Guess the bird!"
                self.loadImage()
                self.timeStart()
                    }
    }
    }
    //Show the "View Result" button
    func showResultButton() {
          resultButton.isHidden = false
          UIView.animate(withDuration: 0.3) {
              self.resultButton.alpha = 1
          }
      }
    //Display Bird Image Stage
    func loadImage() {
        guard let puzzle = puzzle else {
            print("Puzzle is nil")
            return
        }

        guard let url = GetImageURL(id: puzzle.image, index: currentImageIndex) else {
            print("Invalid URL")
            return
        }

        ImageLoader.shared.loadImage(from: url) { [weak self] image in
            guard let self = self else { return }
            if let image = image {
                self.birdImageView.image = image
            } else {
                print("Failed to load image")
            }
        }
    }
    //the final clear image
    func moveFinalImage(){
        currentImageIndex = 5
        loadImage()
    }
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
    }
    // Prepare Data for Result Screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCompleteSegue" {
            if let completeVC = segue.destination as? CompleteViewController {
                completeVC.tries = attempts
                completeVC.birdName = puzzle.name
                completeVC.timeTaken = seconds
                completeVC.photographer = puzzle.photographer
                completeVC.license = puzzle.license
                completeVC.infoURL = puzzle.bird_link
                completeVC.birdImage = birdImageView.image
            }
        }
    }

    // User submit guess
    @objc private func submitGuess(){
        
        let guess = guessTextField.text
        
        if guess == nil || guess!.trimmingCharacters(in: .whitespaces).isEmpty{
            showAlert(title: "OOPSSS", message: "Please enter a guess")
            return}
        attempts += 1
        
        // CORRECT GUESS
        if guess?.lowercased() == puzzle.name.lowercased(){
            stopTime()
            
            moveFinalImage()
            showAlert(title:"Excellent! That's correct",
                      message: "The result is \(puzzle.name). Attempts: \(attempts)")
            saveHistory(
                finalImage: birdImageView.image!,
                        birdName: puzzle.name,
                        infoURL: puzzle.bird_link,
                        timeTaken: Double(seconds),
                        attemptsCount: attempts,
                        isSuccess: true
                )
            guessTextField.isEnabled = false
            startPuzzle.isEnabled = false
            showResultButton()
            return
        }
        //WRONG ANSWER
        else{
            //Run out of attempts (=5)
            if attempts == maxAttempts{
                stopTime()
                moveFinalImage()
                guard let finalImage = birdImageView.image else {
                    showAlert(title: "Error", message: "No image found to save.")
                    return
                }
                saveHistory(
                    finalImage: birdImageView.image!,
                            birdName: puzzle.name,
                            infoURL: puzzle.bird_link,
                            timeTaken: Double(seconds),
                            attemptsCount: attempts,
                            isSuccess: false
                    )
                showAlert(title: "Ooops. Game over!", message: "The result is \(puzzle.name)")
                guessTextField.isEnabled = false
                    startPuzzle.isEnabled = false
                showResultButton()
                
                return
            }
            //Still have attempts
            else{
                currentImageIndex += 1
                loadImage()
                showAlert(title: "Oh noo. That's wrong", message: "You have \(maxAttempts - attempts) left. Try again")
                guessTextField.text = ""
            }
        }
    }
    // Timer Functions
    private func timeStart(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timeCounting), userInfo: nil, repeats: true)
    }
    
    @objc private func timeCounting(){
        
        if seconds >= 24 * 3600 {
            stopTime()
            timeCount.text = "24:00:00"
            return
        }
        seconds += 1
        let hours = seconds / 3600
        let mins = (seconds % 3600) / 60
        let sec = seconds % 60
        timeCount.text = String(format: "%02d:%02d:%02d", hours, mins, sec)
    }
    
    private func stopTime(){
        timer?.invalidate()
        timer = nil
    }
    //Custom UI Styling
    private func customUI(){
            //Custom text field
            guessTextField.layer.borderWidth = 4
            guessTextField.layer.borderColor = UIColor.yellow.cgColor
            guessTextField.layer.cornerRadius = 8
            guessTextField.clipsToBounds = true
            
            //Custom image view
            birdImageView.layer.borderWidth = 5
        
            birdImageView.layer.borderColor = UIColor.white.cgColor
            birdImageView.layer.cornerRadius = 10
            birdImageView.clipsToBounds = true;
            
            //Custom button
            startPuzzle.setTitleColor(.black, for: .normal)
            
            //Custom label
            titlePuzzle.textColor = .white
            titlePuzzle.layer.cornerRadius = 10
            titlePuzzle.clipsToBounds = true
            
            
            //Timer label
            timeCount.layer.cornerRadius = 8
            timeCount .clipsToBounds = true
            timeCount.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
            timeCount.text = "00:00:00"
        }
    }




