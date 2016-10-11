//
//  DetailViewController.swift
//  Philips Hue
//
//  Created by Kasper Balink on 30/09/2016.
//  Copyright © 2016 Kasper Balink. All rights reserved.
//

import UIKit
import Alamofire

class DetailViewController: UIViewController {
    
    var lamp : HueLamp!
    var url : String!
    var color : UIColor!
    @IBOutlet weak var switchOutlet: UISwitch!
    @IBOutlet weak var hueSliderOutlet: UISlider!
    @IBOutlet weak var briSliderOutlet: UISlider!
    @IBOutlet weak var satSliderOutlet: UISlider!
    @IBOutlet weak var colorViewOutlet: UIImageView!

    
    var hue : Int?
    var bri : Int?
    var sat : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        title = lamp.name

        if(lamp?.onState == 1)
        {
        switchOutlet.setOn(true, animated: true)
        }
        else
        {
        switchOutlet.setOn(false, animated: true)
        }
        
        hue = Int(lamp.hue!)
        bri = Int(lamp.bri!)
        sat = Int(lamp.sat!)
        
        
        hueSliderOutlet.value = Float(lamp.hue!)
        briSliderOutlet.value = Float(lamp.bri!)
        satSliderOutlet.value = Float(lamp.sat!)
        url = url + lamp.id! + "/state/"
        print(url)
        
        setColor()
    }
    
    
    @IBAction func switchChangedValue(_ sender: AnyObject)
    {
        var parameters : [String: Any]
        if(switchOutlet.isOn)
        {
            print("on")
            parameters = ["on": true]
        }
        else{
            print("off")
            parameters = ["on": false]
        }
        print(parameters)
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON {
            response in
            if let json = response.result.value
            {
                print(json)
            }
        }
        setColor()
    }
    
    @IBAction func hueSliderChanged(_ sender: AnyObject) {
        let parameters = ["hue": Int(hueSliderOutlet.value)]
        hue = Int(hueSliderOutlet.value)
            print(parameters)
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON {
            response in
            if let json = response.result.value
            {
                print(json)
            }
        }
        setColor()
    }
    
    
    @IBAction func briSliderChanged(_ sender: AnyObject) {
        let parameters = ["bri": Int(briSliderOutlet.value)]
        bri = Int(briSliderOutlet.value)
        print(parameters)
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON {
            response in
            if let json = response.result.value
            {
                print(json)
            }
        }
        setColor()
    }
    
    @IBAction func satSliderChanged(_ sender: AnyObject) {
        let parameters = ["sat": Int(satSliderOutlet.value)]
        sat = Int(satSliderOutlet.value)
        print(parameters)
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON {
            response in
            if let json = response.result.value
            {
                print(json)
            }
        }
        setColor()
    }
    
    func setColor()
    {
        let hueImage : CGFloat = CGFloat((Double(hue!)) / 65535.0)
        let saturationImage : CGFloat = CGFloat(Double(sat!) / 255.0)
        let brightnessImage : CGFloat = CGFloat(Double(bri!) / 255.0)
        let alphaImage : CGFloat = 1.0
        let color = UIColor.init(hue: hueImage, saturation: saturationImage, brightness: brightnessImage, alpha: alphaImage)
        
        colorViewOutlet.backgroundColor = color
    }
    
    
    

}
