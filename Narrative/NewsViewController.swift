//
//  NewsViewController.swift
//  Narrative
//
//  Created by Ashish Keshan on 11/15/16.
//  Copyright © 2016 Scope. All rights reserved.
//

import UIKit
import AVFoundation

class NewsViewController: UIViewController {
     var endpoint: String = ""
     var articles: [NSDictionary?] = []
    let speechClass = AVSpeechSynthesizer()
    
    @IBAction func getCNN(_ sender: Any) {
        endpoint = "cnn"
       
    }
    @IBAction func getBuzzFeed(_ sender: Any) {
        endpoint = "buzzfeed"
    }
    
    @IBAction func getArticles(_ sender: Any) {
        
        let apiKey = "9f3c7070c1994eabb1363dcde6dd317c"
        let url = URL(string: "https://newsapi.org/v1/articles?source=\(endpoint)&apiKey=\(apiKey)")
        let request = URLRequest(
            url: url!,cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    
                    self.articles = (responseDictionary["articles"] as! [NSDictionary])
                   // print("response: \(responseDictionary)")
                    for i in self.articles {
                        let dict = i! as NSDictionary
                        //print(dict)
                        let url = dict["url"] as! String
                        let descript = dict["description"] as! String
                        print(descript)
                        let speak = AVSpeechUtterance(string: descript)
                        speak.voice = AVSpeechSynthesisVoice(language: "en-GB")
                        self.speechClass.speak(speak)
                        print(url)
                    }
                    
                }
            }
        })
        task.resume()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
                // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
