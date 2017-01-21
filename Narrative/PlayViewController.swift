//
//  ViewController.swift
//  Narrative
//
//  Created by Alex Pareto on 11/15/16.
//  Copyright © 2016 Scope. All rights reserved.
//

import UIKit
import AVFoundation

    var label: UILabel?
    let stations = ["cnn", "buzzfeed", "espn", "bbc-news"]

class PlayViewController: UIViewController {
    var endpoint: String = ""
    var articles: [NSDictionary?] = []
    let speechClass = AVSpeechSynthesizer()
    let isTalking = false;
    
    var sourceID = "cnn"
    let apiKey = "9f3c7070c1994eabb1363dcde6dd317c"
    var url = URL(string:"")
    var stationName = "CNN"
    
//    let url = URL(string: "https://newsapi.org/v1/articles?source=cnn&apiKey=9f3c7070c1994eabb1363dcde6dd317c")
//    var url = URL(string: "https://newsapi.org/v1/articles?source=&apiKey=9f3c7070c1994eabb1363dcde6dd317c")

    
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var pulseImage: UIImageView!
    @IBAction func getArticles(_ sender: Any) {
        
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = FLT_MAX
        pulseImage.layer.add(pulseAnimation, forKey: "animateOpacity")
        
        
        if (speechClass.isSpeaking && !speechClass.isPaused) {
            self.speechClass.pauseSpeaking(at: AVSpeechBoundary.immediate)
            pulseImage.layer.removeAllAnimations()
        }
        else if (speechClass.isPaused) {
            pulseImage.layer.add(pulseAnimation, forKey: "animateOpacity")
            self.speechClass.continueSpeaking()
        }
        else {
        
//            let apiKey = "9f3c7070c1994eabb1363dcde6dd317c"
//            let url = URL(string: "https://newsapi.org/v1/articles?source=cnn&apiKey=\(apiKey)")
            
            let request = URLRequest(url: url!,cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        
            let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    
//                        print("Response dictionary: \(responseDictionary)")
                        self.articles = (responseDictionary["articles"] as! [NSDictionary])
                    
                        for i in self.articles {
                            let dict = i! as NSDictionary
                            print("Dict: \(dict["description"])")
                            
                            let descript = dict["description"] as! String
                            
//                            var descript = ""
//                            if (dict["description"]! != nil) {
//                                descript = dict["description"] as! String
//                            }
                            
                            let speak = AVSpeechUtterance(string: descript)
                            speak.voice = AVSpeechSynthesisVoice(language: "en-GB")
                            self.speechClass.speak(speak)
                       }
                    }
                }
            })
        
            task.resume()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let slideControl = DHSlideControl(titles: stations)
        slideControl.translatesAutoresizingMaskIntoConstraints = false
        slideControl.addTarget(self, action: #selector(PlayViewController.didChange(_:)), for: .valueChanged)
        slideControl.color = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.0)
        slideControl.layer.cornerRadius = 10
        
        label = UILabel()
        label?.translatesAutoresizingMaskIntoConstraints = false
        label?.text = stations.first
        label?.textAlignment = .center
        label?.textColor = UIColor.lightGray
        
        view.addSubview(slideControl)
        view.addSubview(label!)
        
        let views = ["slide": slideControl, "label": label!] as [String : Any]
        
        var layoutConstraints = [NSLayoutConstraint]()
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "|-20-[slide]-20-|", options: [], metrics: nil, views: views)
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[slide(80)]-50-[label]", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        NSLayoutConstraint.activate(layoutConstraints)


        
        
        
        url = URL(string: "https://newsapi.org/v1/articles?source=\(self.sourceID)&apiKey=\(self.apiKey)") // Update url after new station is chosen
        //self.stationLabel.text = self.stationName // Update stationLabel after a station is chosen
        
        self.speechClass.pauseSpeaking(at: AVSpeechBoundary.immediate)
        pulseImage.layer.removeAllAnimations()
        print("View loaded again")
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//            self.speechClass.pauseSpeaking(at: AVSpeechBoundary.immediate)
//            pulseImage.layer.removeAllAnimations()
//        
//    }
    
    func didChange(_ sender: DHSlideControl) {
        print(sender.selectedIndex)
        label?.text = stations[sender.selectedIndex]
        self.sourceID = stations[sender.selectedIndex]
        url = URL(string: "https://newsapi.org/v1/articles?source=\(self.sourceID)&apiKey=\(self.apiKey)") // Update url
        
        self.speechClass.stopSpeaking(at: AVSpeechBoundary.immediate)
        pulseImage.layer.removeAllAnimations()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

