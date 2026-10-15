//
//  StartViewController.swift
//  Assignment2
//
//  Created by user276180 on 11/12/25.
//

//
//  ViewController.swift
//  Assignment2
//
//  Created by user276180 on 11/12/25.
//

import UIKit

class StartViewController: UIViewController {

    
    @IBOutlet var moreButton: UIButton!
    @IBOutlet weak var startPuzzle: UIButton!
    
   
    @IBOutlet var popupMenuView: UIView!
    
    override func viewDidLoad() {
           super.viewDidLoad()
           popupMenuView.isHidden = true  // ẩn popup ban đầu
        UIDesign()
       }

       @IBAction func moreButtonTapped(_ sender: UIButton) {
          
           popupMenuView.isHidden.toggle()
       }
    func UIDesign(){
        popupMenuView.layer.cornerRadius = 10
            popupMenuView.clipsToBounds = true
        popupMenuView.layer.borderColor = UIColor.lightGray.cgColor
        popupMenuView.layer.borderWidth = 2.0
    }
      

}

