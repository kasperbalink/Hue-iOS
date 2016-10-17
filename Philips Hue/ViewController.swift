//
//  ViewController.swift
//  Philips Hue
//
//  Created by Kasper Balink on 30/09/2016.
//  Copyright © 2016 Kasper Balink. All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class ViewController: UITableViewController {
    
    var hueLamps: [HueLamp] = []
    var url = ""
    @IBOutlet var hueLampTableView: UITableView!
    
    @IBOutlet var activityIndicatorOutlet: UIActivityIndicatorView!
    
    //www.meethue.com/api/nupnp
    
    
    let alert = UIAlertController(title: "No connection found", message:"Can't connect to a Philips Hue Bridge. Is the correct location set?", preferredStyle: .alert)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //        let userDefaults = UserDefaults.standard.string(forKey: "locationSetting")
        //        if(userDefaults == "School")
        //        {
        //            title = "School"
        //            url = "http://145.48.205.33/api/iYrmsQq1wu5FxF9CPqpJCnm1GpPVylKBWDUsNDhB/lights/"
        //        }
        //        else if(userDefaults == "SchoolMAD")
        //        {
        //            title = "School MAD"
        //            url = http://192.168.1.179/api/366de469293bba57ef371add115f7b/lights/
        //        }
        //        else
        
        //        {
        //            title = "Home"
        //            url = "http://192.168.1.13/api/7fhuy-WsU2PWUaHh6SQslkyGpCIqpjlh1jFewoQt/lights/"
        //        }
        
        self.refreshControl?.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.refreshControl?.backgroundColor = UIColor.lightGray
        
        
        
        
        getHueLamps()
        hueLampTableView.allowsSelection = false
        hueLampTableView.allowsSelection = true
        //activityIndicatorOutlet.startAnimating()
        hueLampTableView.reloadData()
        
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        getHueLamps()
        hueLampTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hueLamps.removeAll()
        getHueLamps()
    }
    
    func getHueLamps() {
        self.hueLamps.removeAll()
        // Doe de .GET
        EZLoadingActivity.show("Loading...", disableUI: true)
        Alamofire.request(url, method: .get, encoding: URLEncoding.default).responseJSON
            {
                response in
                if(response.result.error == nil && response.result.value != nil)
                {
                    self.hueLamps.removeAll()
                    EZLoadingActivity.hide(true, animated: true)
                    
                    // Hier json parsen
                    if let json = response.result.value as? Dictionary<String, Any>
                    {
                        
                        for (key, _) in json{
                            
                            let lamp = json[key] as! Dictionary<String, Any>
                            let state = lamp["state"] as! Dictionary<String, Any>
                            
                            if((lamp["type"] as! String) != "Dimmable light")
                            {
                                let onState = state["on"] as! Int
                                let hue = state["hue"] as! Int
                                let bri = state["bri"] as! Int
                                let sat = state["sat"] as! Int
                                let name = lamp["name"] as! String
                                
                                let tmpLamp = HueLamp(id: key, name: name, onState: onState, hue: hue, bri: bri, sat: sat)
                                self.hueLamps.append(tmpLamp)
                                self.hueLampTableView.reloadData()
                            }
                        }
                    }
                }
                else{
                    if(!self.alert.isViewLoaded)
                    {
                        EZLoadingActivity.hide(false, animated: true)
                        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                                return
                            }
                            
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            }
                        }
                        
                        self.alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                        self.alert.addAction(settingsAction)
                        
                        self.present(self.alert, animated: true){}
                    }
                }
        }
        refreshControl?.endRefreshing()
        hueLampTableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hueLamps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HueCell", for: indexPath) as! HueCell
        let row = indexPath.row
        
        let hueImage : CGFloat = CGFloat((Double(hueLamps[row].hue!)) / 65535.0)
        let saturationImage : CGFloat = CGFloat(Double(hueLamps[row].sat!) / 255.0)
        let brightnessImage : CGFloat = CGFloat(Double(hueLamps[row].bri!) / 255.0)
        let alphaImage : CGFloat = 1.0
        let color = UIColor.init(hue: hueImage, saturation: saturationImage, brightness: brightnessImage, alpha: alphaImage)
        
        cell.colorView.backgroundColor = color
        cell.nameLabel.text = hueLamps[row].name
        
        
        
        if(hueLamps[row].onState == 1)
        {
            cell.stateLabel.text = "On"
        }
        else
        {
            cell.stateLabel.text = "Off"
            
        }
        return cell;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailView" {
            if let destination = segue.destination as? DetailViewController
            {
                if let indexPath = self.tableView.indexPathForSelectedRow
                {
                    let hueLamp = hueLamps[(indexPath as NSIndexPath).row]
                    destination.lamp = hueLamp
                    destination.url = url
                }
            }
        }
    }
    
    
}

