//
//  ViewController.swift
//  SleepTalkRecorder
//
//  Created by Yang Jin on 12/18/18.
//  Copyright © 2018 Yang Jin. All rights reserved.
//

import UIKit
import AVFoundation
import CoreAudio

class RecorderViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    var recording = false
    var numRecordings = 0
    var loudSoundFileBaseURL: URL!
    var recordSettings: Dictionary<String, Any>!
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var loudAudioRecorder: AVAudioRecorder?
    var levelTimer: Timer?
    var newVoice: Voice?
    var playlist = [Voice]()
    
    @IBOutlet var recordButton: [UIButton]!
    
    @IBOutlet var stopButton: [UIButton]!
    
    @IBOutlet var playButton: [UIButton]!
    
    @IBOutlet var playlistButton: [UIButton]!
    
    @IBOutlet var storeButton: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileMgr = FileManager.default
        
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        loudSoundFileBaseURL = dirPaths[0]
        
        let soundFileURL = loudSoundFileBaseURL.appendingPathComponent("sound.caf")
        let loudSoundFileURL = loudSoundFileBaseURL.appendingPathComponent("loudSound"+String(numRecordings)+".caf")
        
        recordSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0] as [String : Any]
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL,
                                                settings: recordSettings as [String : AnyObject])
            audioRecorder?.prepareToRecord()
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        print (loudSoundFileURL)
        do {
            try loudAudioRecorder = AVAudioRecorder(url: loudSoundFileURL,
                                                settings: recordSettings as [String : AnyObject])
            loudAudioRecorder?.prepareToRecord()
            loudAudioRecorder?.isMeteringEnabled = true
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        levelTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(RecorderViewController.levelTimerCallback), userInfo: nil, repeats: true)
    }
    
    @IBAction func startRecord(_ sender: Any) {
//        if loudAudioRecorder?.isRecording == false {
//            loudAudioRecorder?.record()
//        }
        recording = true
    }
    
    @IBAction func stopRecord(_ sender: Any) {
        recording = false
        loudAudioRecorder?.stop()
        newVoice = Voice(name: "Voice #"+String(numRecordings), url: loudAudioRecorder!.url)
    }
    
    @IBAction func playRecord(_ sender: Any) {
        if loudAudioRecorder?.isRecording == false {

            do {
                try audioPlayer = AVAudioPlayer(contentsOf:
                    (loudAudioRecorder?.url)!)
                audioPlayer!.delegate = self
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func storeRecord(_ sender: Any) {
        playlist.append(newVoice!)
        numRecordings += 1
        let loudSoundFileURL = loudSoundFileBaseURL.appendingPathComponent("loudSound"+String(numRecordings)+".caf")
        do {
            try loudAudioRecorder = AVAudioRecorder(url: loudSoundFileURL,
                                                    settings: recordSettings as [String : AnyObject])
            loudAudioRecorder?.prepareToRecord()
            loudAudioRecorder?.isMeteringEnabled = true
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio Play Decode Error")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Record Encode Error")
    }
    
    @objc func levelTimerCallback(){
//        print (audioRecorder?.averagePower(forChannel: 0) ?? -1000)
//        if loudAudioRecorder?.isRecording == false {
//            return
//        }
        if recording {
            if (audioRecorder?.averagePower(forChannel: 0).isLess(than: -50))! {
                loudAudioRecorder?.pause()
            } else {
                loudAudioRecorder?.record()
            }
        }
        audioRecorder?.updateMeters()
//        if audioRecorder?.averagePowerForChannel(0) > 0.0 {
//            if audioRecorder?.isRecording == false {
//
//            }
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destinationVC = segue.destination as! PlaylistTableViewController
        destinationVC.playlist = playlist
        
//        print (destinationVC)
//        print (destinationVC.newVoice)
        print ("add new voice!!")
    }
}
