//
//  scoresPage.swift
//  Wormhole
//
//  Created by Alexi Chryssanthou on 3/11/18.
//  Copyright © 2018 Alexi Chryssanthou. All rights reserved.
//

import UIKit

class scoresPage: UIView {
    
    //MARK: - Properties
    
    var parentVC: MenuController!
    
    //MARK: - Initialization
    
    override init (frame : CGRect) {
        super.init(frame : CGRect(x: frame.minX, y: frame.height, width: 0.75*frame.width, height: 0.75*frame.height))
        center = CGPoint(x: frame.midX, y: frame.maxY+frame.midY)
        backgroundColor = UIColor.init(red: 19/255, green: 22/255, blue: 41/255, alpha: 0.8)
        layer.borderWidth = 2
        layer.borderColor = UIColor(red: 72/255, green: 234/255, blue: 127/255, alpha: 1.0).cgColor
        layer.cornerRadius = 12
        layer.masksToBounds = true
        makeLabel()
        makeText()
        
        let singeTap = UITapGestureRecognizer(target: self, action: #selector(exitHighScores(_:)))
        self.addGestureRecognizer(singeTap)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    //MARK: - Make Elements
    
    // makes and formats the label for the view
    func makeLabel() {
        let width = self.frame.size.width
        let height = self.frame.size.height
        // make the label
        let label: UILabel = UILabel()
        label.frame = CGRect(x:0, y:height*0.05, width:width, height:height*0.25)
        label.backgroundColor = UIColor.init(red: 1.0, green:1.0, blue: 1.0, alpha: 0.0)
        
        // format the text
        label.textAlignment = NSTextAlignment.center
        let fontSize = CGFloat(height > 250 ? 26 : 22)
        label.font = UIFont(name:"Virgo01", size: fontSize)
        label.textColor = UIColor(red: 234/255, green: 72/255, blue: 127/255, alpha: 1.0)
        label.text = "High Scores"
        
        // add the label to view
        self.addSubview(label)
    }
    
    // makes and formats the text for the view
    func makeText() {
        let width = self.frame.size.width
        let height = self.frame.size.height
        
        // get the scores
        let defaults = UserDefaults.standard
        let scores = defaults.array(forKey: "highScores") ?? Array(repeating:0,count:15)
        
        // make three views
        for i in 0...2 {
            // make and shape the text view
            let txtView: UITextView = UITextView()
            let newWidth = width*0.07*CGFloat(i+1) + width*0.24*CGFloat(i)
            txtView.frame = CGRect(x:newWidth, y:height*0.30, width:width*0.24, height:height*0.65)
            txtView.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        
            // make the text
            for j in (i*5)...((i+1)*5-1) {
                txtView.text = txtView.text+"\(j+1). \(scores[j])\n\n"
            }
        
           // format the text
            let fontSize = CGFloat(height > 250 ? 16 : 13)
            txtView.font = UIFont(name: "Virgo01", size: fontSize)
            txtView.textColor = UIColor(red: 234/255, green: 72/255, blue: 168/255, alpha: 1.0)
            txtView.textAlignment = NSTextAlignment.left
            txtView.isEditable = false
            txtView.isSelectable = false
            txtView.isScrollEnabled = false
        
            // add text to view
            self.addSubview(txtView)
        }
    }
    
    //MARK: - Actions
    
    // animates the high score table away and reshows the score and run button
    @IBAction func exitHighScores(_ sender: UITapGestureRecognizer) {
        print("Closing High Scores Page.")
        UIView.animate(withDuration: 0.8, delay: 0.0, animations: {
            self.transform = CGAffineTransform(translationX:0, y:700)
        }, completion: { (finished) -> Void in self.removeFromSuperview() }
        )
        parentVC.highScoreButton.isEnabled = true
        parentVC.startRunButton.isEnabled = true
    }
    
}
