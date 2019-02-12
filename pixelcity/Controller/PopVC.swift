//
//  PopVC.swift
//  pixelcity
//
//  Created by Graphene on 12/2/19.
//  Copyright © 2019 tam-lam. All rights reserved.
//

import UIKit

class PopVC: UIViewController , UIGestureRecognizerDelegate{

    @IBOutlet weak var popImageView: UIImageView!
    var passedImage: UIImage!
    
    func initImage(forImage passedImage: UIImage){
        self.passedImage = passedImage
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        
        addDoubleTapGesture()
    }
    
    func addDoubleTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PopVC.dismissTap))
        tapGesture.numberOfTapsRequired = 2
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissTap(){
        dismiss(animated: true, completion: nil)
    }
}
