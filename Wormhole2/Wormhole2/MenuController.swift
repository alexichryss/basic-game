//
//  MenuController.swift
//  Wormhole
//
//  Created by Alexi Chryssanthou on 5/27/18.
//  Copyright © 2018 Alexi Chryssanthou. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class MenuController: UIViewController {
    
    //MARK: - Parameters
    
    var backgroundMusicPlayer = AVAudioPlayer()
    
    @IBOutlet weak var startRunButton: UIButton!
    @IBOutlet weak var highScoreButton: UIButton!
    @IBOutlet weak var titleImage: UIImageView!


    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playBackgroundMusic("titleMusic")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        view.bringSubview(toFront: titleImage)
        view.bringSubview(toFront: startRunButton)
        view.bringSubview(toFront: highScoreButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        hideTitleElements(false)
    }
    
    //MARK: - Actions
    
    // initializes the game objects and starts the run
    @IBAction func StartRun(_ sender: UIButton) {
        startGame()
        defer { print("Game has started.") }
    }
    
    @IBAction func showHighScores(_ sender: UIButton) {
        print("Displaying High Scores Page.")
        highScoreButton.isEnabled = false
        startRunButton.isEnabled = false
        
        let scores = scoresPage(frame: self.view.frame)
        scores.parentVC = self
        self.view.addSubview(scores)
        UIView.animate(withDuration: 0.6) {
            scores.center = self.view.center
        }
    }

    //MARK: - Custom Methods

    // creates blocks and ship, starts game music, pauses stars and title music
    func startGame() {

        hideTitleElements(true)

        backgroundMusicPlayer.pause()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        if let scene = GKScene(fileNamed: "GameScene") {

            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {

                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities

                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .resizeFill

                // Set the GameOverDelegate
                sceneNode.vcDelegate = self

                // Present the scene
                let view = SKView(frame: UIScreen.main.bounds)
                self.view.addSubview(view)
                let transition = SKTransition.fade(withDuration: 0.5)
                view.presentScene(sceneNode, transition: transition)

                view.ignoresSiblingOrder = true

                view.showsFPS = true
                view.showsNodeCount = true

            }
        }
    }

    // toggle view elements and gestures for game states
    func hideTitleElements(_ toggle: Bool) {

        startRunButton.isHidden = toggle
        highScoreButton.isHidden = toggle
        titleImage.isHidden = toggle
    }
    
    //MARK: - Preferences
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        print("Returning from Game Scene.")
    }
    
    //MARK: - Delegate Method
    func dismissGameOver(_ view: SKView) {
        view.removeFromSuperview()
        self.performSegue(withIdentifier: "Restart", sender: self)
        hideTitleElements(false)
        backgroundMusicPlayer.play()
    }
}

