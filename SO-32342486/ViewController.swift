//
//  ViewController.swift
//  SO-32342486
//
//  Copyright © 2017 Xavier Schott
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!

    var progressLink : CADisplayLink? = nil
    @IBOutlet weak var recordingActivity: UIActivityIndicatorView!
    @IBOutlet weak var playProgress: UIProgressView!

    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC) as Int32),
                          AVNumberOfChannelsKey : NSNumber(value: 1 as Int32),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32)]

    override func viewDidLoad() {
        super.viewDidLoad()

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: directoryURL()!,
                                                settings: recordSettings)
            audioRecorder.prepareToRecord()
        } catch {}
    }

    @IBAction func doRecordAction(_ sender: AnyObject) {
        playProgress.setProgress(0, animated: false)
        recordingActivity.startAnimating()
        recordingActivity.isHidden = false

        if !audioRecorder.isRecording {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
            } catch {}
        }
    }

    @IBAction func doPlayAction(_ sender: AnyObject) {
        if !audioRecorder.isRecording {
            do {
                playProgress.setProgress(0, animated: false)

                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                progressLink = CADisplayLink(target: self,
                                             selector: #selector(ViewController.playerProgress))
                if let progressLink = progressLink {
                    progressLink.frameInterval = 2
                    progressLink.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                }
                audioPlayer.delegate = self
                audioPlayer.play()
            } catch {}
        }
    }

    @IBAction func doStopAction(_ sender: AnyObject) {
        audioRecorder.stop()
        recordingActivity.stopAnimating()

        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setActive(false)
        } catch {}
    }

    func playerProgress() {
        var progress = Float(0)
        if let audioPlayer = audioPlayer {
            progress = ((audioPlayer.duration > 0)
                ? Float(audioPlayer.currentTime/audioPlayer.duration)
                : 0)
        }
        playProgress.setProgress(progress, animated: true)
    }

    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent("SO-32342486")
        return soundURL
    }
}

extension ViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let progressLink = progressLink {
            progressLink.invalidate()
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let progressLink = progressLink {
            progressLink.invalidate()
        }
    }
}
