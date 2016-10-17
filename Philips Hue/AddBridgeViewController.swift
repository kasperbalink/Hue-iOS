//
//  AddBridgeViewController.swift
//  Philips Hue
//
//  Created by Kasper Balink on 13/10/2016.
//  Copyright © 2016 Kasper Balink. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddBridgeViewContoller : UITableViewController
{
    var bridges : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select bridge IP"
        
        let url = "https://www.meethue.com/api/nupnp"
        Alamofire.request(url, method: .get).responseJSON
            {
                response in
                if let data = response.result.value
                {
                    let Json = JSON(data)
                    for i in 0 ... Json.count-1
                    {
                        let ip = Json[i]["internalipaddress"]
                        self.bridges.append(ip.string!)
                        self.tableView.reloadData()
                    }
                }
        }
    }    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bridges.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IpCell", for: indexPath)
        let row = indexPath.row
        
        cell.textLabel?.text = bridges[row]
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(bridges[indexPath.row])
        createNewUser(url: bridges[indexPath.row])
    }
    
    func createNewUser(url : String)
    {
        let alertController = UIAlertController(title: "Press link button", message:
            "Press link button and press Ok", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.addBridge(urlA: url)
        }
        
        // Add the actions
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)

        
    }
    
    func addBridge(urlA : String)
    {
        let url = "http://" + urlA + "/api"
        let randomNumber = String(100 + arc4random_uniform(200))
        let type = "kasper_hue_app#" + randomNumber
        let parameter = ["devicetype" : type]
        Alamofire.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default).responseJSON
            {
                response in
                if let data = response.result.value
                {
                    let Json = JSON(data)
                    if(Json[0]["success"] != nil)
                    {
                        print(Json[0]["success"])
                         let apiKey = Json[0]["success"]["username"].string!
                         let finalUrl = "http://" + urlA + "/"
                         self.addBridgeToDB(url : finalUrl, apiKey : apiKey)
                         print(finalUrl)
                         print(apiKey)
                    }
                    else if(Json[0]["error"] != nil){
                        print(Json[0]["error"])
                        let alert = UIAlertController(title: "Error", message:
                            Json[0]["error"]["description"].string!, preferredStyle: UIAlertControllerStyle.alert)
                        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel)
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)

                    }
                    else{
                        print(Json[0])
                        print(".........")
                    }
                    
                }
        }
    }
    
    
    func addBridgeToDB(url : String, apiKey : String)
    {
        let hdbh = HueDatabaseHelper.sharedInstance
        print("addBridgeToDB:")
        print(url)
        print(apiKey)
        print("-------------")
        if(hdbh.addBridge(url: url, apiKey: apiKey) == 1)
        {
            //TODO - return 
        }
        
    }


}
