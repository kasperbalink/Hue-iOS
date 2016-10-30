//
//  BridgeViewController.swift
//  Philips Hue
//
//  Created by Kasper Balink on 13/10/2016.
//  Copyright © 2016 Kasper Balink. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BridgeViewController : UITableViewController
{
    
    var ipsToAdd: [String] = []
    var bridges: [HueBridge] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let hdbh = HueDatabaseHelper.sharedInstance
        bridges = hdbh.getBridges()!
        title = "Bridges"
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.refreshControl?.backgroundColor = UIColor.lightGray
        self.navigationItem.rightBarButtonItem = add;
        self.tableView.reloadData()
    }
    
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        let hdbh = HueDatabaseHelper.sharedInstance
        bridges = hdbh.getBridges()!
        tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    func addTapped()
    {
        performSegue(withIdentifier: "toAddBridgeViewController", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let hdbh = HueDatabaseHelper.sharedInstance
        bridges = hdbh.getBridges()!
        tableView.reloadData()
    }
    
    
    func fillArrayWithDefaultData()
    {
        let bridge = HueBridge()
        bridge.name = "Home"
        bridge.url = "http://192.168.1.13/"
        bridge.apiKey = "7fhuy-WsU2PWUaHh6SQslkyGpCIqpjlh1jFewoQt"
        bridges.append(bridge)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete button tapped")
            self.removeFromDB(apiKey: self.bridges[(indexPath as NSIndexPath).row].apiKey!)
        }
        delete.backgroundColor = UIColor.red
        
        let name = UITableViewRowAction(style: .normal, title: "Change name") { action, index in
            print("change name button tapped")
            self.changeName(apiKey: self.bridges[(indexPath as NSIndexPath).row].apiKey!)
        }
        name.backgroundColor = UIColor.blue
        return [delete, name]
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bridges.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BridgeCell", for: indexPath)
        let row = indexPath.row
        
        cell.textLabel?.text = bridges[row].name
        return cell;
    }
    
    func removeFromDB(apiKey : String)
    {
        let hdbh = HueDatabaseHelper.sharedInstance
        if(hdbh.removeBridge(apiKey: apiKey) == 1)
        {
            bridges = hdbh.getBridges()!
            tableView.reloadData()
        }
    }
    
    
    
    var tField: UITextField!
    func configurationTextField(textField: UITextField!)
    {
        textField.placeholder = "Home"
        tField = textField
    }
    func changeName(apiKey : String)
    {
        let altMessage = UIAlertController(title: "Warning", message: "This is Alert Message", preferredStyle: UIAlertControllerStyle.alert)
        altMessage.addTextField(configurationHandler: configurationTextField)
        let okAction = UIAlertAction(title: "Change", style: UIAlertActionStyle.default) {
            UIAlertAction in
            let hdbh = HueDatabaseHelper.sharedInstance
            if(hdbh.changeName(apiKey: apiKey, newName: self.tField.text!) == 1)
            {
                self.bridges = hdbh.getBridges()!
                self.tableView.reloadData()
            }
            else{
                print("Changing name failed")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            print("cancel pressed")
        }
        altMessage.addAction(okAction)
        altMessage.addAction(cancelAction)
        
        self.present(altMessage, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHueLampView" {
            if let destination = segue.destination as? ViewController
            {
                if let indexPath = self.tableView.indexPathForSelectedRow
                {
                    let url = bridges[(indexPath as NSIndexPath).row].url! + "api/" + bridges[(indexPath as NSIndexPath).row].apiKey! + "/lights/"
                    print(url)
                    destination.url = url
                    destination.title = bridges[(indexPath as NSIndexPath).row].name!
                }
            }
        }
    }
    
}
