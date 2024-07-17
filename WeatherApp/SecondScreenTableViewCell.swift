//
//  SecondScreenTableViewCell.swift
//  WeatherApp
//
//  Created by Neha on 2024-07-14.
//

import UIKit

class SecondScreenTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var weatherConditionImg: UIImageView!
    @IBOutlet weak var descView: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code


    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
