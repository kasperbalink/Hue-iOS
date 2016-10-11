//
//  HueLamp.swift
//  Philips Hue
//
//  Created by Kasper Balink on 30/09/2016.
//  Copyright © 2016 Kasper Balink. All rights reserved.
//

class  HueLamp
{
    var id : String?
    var hue : Int?
    var bri : Int?
    var sat : Int?
    var onState : Int?
    var name : String?
    
    required init(id : String, name: String, onState : Int, hue : Int, bri : Int, sat : Int)
    {
        self.id = id
        self.name = name
        self.onState = onState
        self.hue = hue
        self.bri = bri
        self.sat = sat
    }
    
    
}
