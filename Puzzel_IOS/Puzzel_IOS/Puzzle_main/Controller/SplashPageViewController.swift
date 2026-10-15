
import Foundation
//
//  ViewController.swift
//  Assignment2
//
//  Created by user276180 on 11/12/25.
//

import UIKit

class SplashPageViewController: UIViewController {
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //make it invisible from the start
        logo.alpha = 0
        label.alpha = 0
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationSplash()
    }
    func animationSplash()
    {
        UIView.animate(withDuration: 3.0, animations: {
            self.logo.alpha = 1
            self.label.alpha = 1
        }) { _ in
            //Bounce for logo
            UIView.animate(withDuration: 1.5, delay: 0,
                           usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
                self.logo.transform = CGAffineTransform(scaleX: 1.7, y: 1.5)
            } completion: { _ in
                //Return to normal size for logo
                UIView.animate(withDuration: 0.3){
                    self.logo.transform = CGAffineTransform.identity} completion: {_ in self.performSegue(withIdentifier: "start", sender: self)
                }
            }
        }
    }}

