//
//  AllMemeTableViewCell.swift
//  MemeMe
//
//  Created by Sujal Ghosh on 09/04/17.
//  Copyright © 2017 Sujal. All rights reserved.
//

import UIKit

class AllMemeTableViewCell: UITableViewCell {
  @IBOutlet weak var memeImageView: UIImageView?
  @IBOutlet weak var memeTextLabel: UILabel?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
