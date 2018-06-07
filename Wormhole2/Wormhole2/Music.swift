//
//  Music.swift
//  Wormhole
//
//  Created by Alexi Chryssanthou on 5/28/18.
//  Copyright © 2018 Alexi Chryssanthou. All rights reserved.
//

import UIKit
import AVFoundation

//MARK: - Music

extension MenuController {

    // plays the title screen bg music with the specified settings
    func playBackgroundMusic(_ filename: String) {
        let url = Bundle.main.url(forResource: filename , withExtension: "mp3")
        guard let newURL = url else {
            print("Could not find file: \(filename).")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: newURL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
            backgroundMusicPlayer.volume = 0.45
            
        } catch let error as NSError {
            print(error.description)
        }
    }
}
