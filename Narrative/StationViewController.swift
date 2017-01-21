// names and nameID keep going out of scope

//
//  StationViewController.swift
//  Narrative
//
//  Created by Janson Lau on 1/3/17.
//  Copyright © 2017 Scope. All rights reserved.
//

import UIKit
import AVFoundation

class StationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var stationTableView: UITableView!
    
    var sources: [NSDictionary?] = []
    var names: [String] = []
    var nameID: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stationTableView.delegate = self
        stationTableView.dataSource = self
        populateNameArray()
//        self.view.bringSubview(toFront: stationTableView)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        self.view.bringSubview(toFront: stationTableView)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateNameArray() {
        let url = URL(string: "https://newsapi.org/v1/sources?language=en")
        
        let request = URLRequest(url: url!,cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    
                    self.sources = (responseDictionary["sources"] as! [NSDictionary]) // Dictionary of all sources
                    
                    for i in self.sources { // For each source
                        let dict = i! as NSDictionary // Get source as dictionary
                        
                        let name = dict["name"] as! String // Save it's name
                        let id = dict["id"] as! String // Save it's ID
                        
                        self.names.append(name)
                        self.nameID.append(id)
                    }
                    let defaults = UserDefaults.standard
                    defaults.set(self.names, forKey: "stationNames")
                    defaults.set(self.nameID, forKey: "stationIDs")
                    defaults.synchronize()
                    self.stationTableView.reloadData()
                }
            }
        })
        
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StationTableViewCell", for: indexPath) as! StationTableViewCell // Reuse the same cell object to render another row that comes into view
        
        cell.stationLabel.text = names[indexPath.row] // Set text label
        return cell
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PlayViewController" {
            self.view.bringSubview(toFront: stationTableView)
            let vc = segue.destination as! PlayViewController
            let indexPath = stationTableView.indexPath(for: sender as! StationTableViewCell)
//            let id = self.nameID[(indexPath?.row)!]
            
            print("Hello World")
//            print("VC SourceID: \(vc.sourceID)")
            vc.sourceID = nameID[(indexPath?.row)!]
            
            print("Name: \(names[(indexPath?.row)!])")
//            print(vc.stationLabel.text)
//            vc.stationLabel.text = names[(indexPath?.row)!]
            vc.stationName = names[(indexPath?.row)!]
//            vc.stationLabel.text = names[(indexPath?.row)!]
            
//            print("VC SourceID: \(vc.sourceID)")
//                vc.speechClass.pauseSpeaking(at: AVSpeechBoundary.immediate)
//            vc.pulseImage.layer.removeAllAnimations()
        }
    }
}
