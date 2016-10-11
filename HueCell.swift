//
//  HueCell.swift
//  Philips Hue
//
//  Created by Kasper Balink on 07/10/2016.
//  Copyright © 2016 Kasper Balink. All rights reserved.
//
import UIKit

class HueCell: UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var colorView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
