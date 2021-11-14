//
//  AudioManager.swift
//  Demo
//
//  Created by Jamil on 22/6/21.
//

import UIKit
import AVFoundation
var player: AVAudioPlayer?

protocol AudioManagerDelegate {
    func recordDidFinish()
}

//current time stamp in milliseconds
extension Date {
    static var timeStamp: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000) //milliseconds
    }
}

class AudioManager: NSObject,AVAudioRecorderDelegate {
    //var recordButton : UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var delegate:AudioManagerDelegate?
    
    enum PlayerStatus {
        case play, pause, stop
    }
    
    func initAudio(){
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                    } else {
                        // failed to record!
                    }
                }
            }
            
        } catch {
            // failed to record!
        }
    }

    func playSound() {
        let url = getDocumentsDirectory().appendingPathComponent("recording.flac")
        print("play url::\(url)")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func soundPlayer(id:Int64? = 0, _ playerStatus: PlayerStatus) {
        //let url = getDocumentsDirectory().appendingPathComponent("recording1636816197506.flac")
        
        let url = getDocumentsDirectory().appendingPathComponent("recording\(id!).flac")
        print("url::\(url)")
//        let urls = AudioManager.allRecordedData()
//        let filteredUrl = urls?.filter { $0 == url }
//        print("url play::\(filteredUrl)")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            switch playerStatus{
            case .play:
                player.play()
            case .pause:
                player.pause()
            case .stop:
                player.stop()
            }
        } catch let error {
            print(error.localizedDescription)
            showAlertOkay(title: "Error!", message: "File not exist.", completion: { _ in })
        }
    }
    
    func startRecording(id:Int64? = 0) {
        print("startRecording")
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(id!).flac")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatFLAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        for path in paths{
            print("path::\(path)")
        }
        
        print("allRecordedData::\(AudioManager.allRecordedData())")
        
       return paths[0]
    }
    
    class func allRecordedData() -> [URL]? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: paths[0], includingPropertiesForKeys: nil)
            return directoryContents.filter{ $0.pathExtension == "flac" }
        } catch {
            return nil
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if let _delegate = self.delegate {
            _delegate.recordDidFinish()
        }
    }
    
    @objc func recordTapped(id:Int64) {
        print("recordTapped")
        if audioRecorder == nil {
            startRecording(id:id)
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
}
