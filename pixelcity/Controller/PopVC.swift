//
//  PopVC.swift
//  pixelcity
//
//  Created by Graphene on 12/2/19.
//  Copyright © 2019 tam-lam. All rights reserved.
//

import UIKit

class PopVC: UIViewController , UIGestureRecognizerDelegate{

    @IBOutlet weak var imageTitleLbl: UILabel!
    @IBOutlet weak var popImageView: UIImageView!
    var passedImage: UIImage!
    var imageTitle: String!
    
    func initImage(forImage passedImage: UIImage, imageTitle title: String){
        self.passedImage = passedImage
        self.imageTitle = title
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        imageTitleLbl.text = imageTitle
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
