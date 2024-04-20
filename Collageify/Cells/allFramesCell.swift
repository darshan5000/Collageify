//
//  allFramesCell.swift
//  Photo Collage Maker
//
//  Created by Grapes Infosoft on 14/09/19.
//  Copyright © 2019 Grapes Infosoft. All rights reserved.
//

import UIKit

class allFramesCell: UICollectionViewCell {

    //MARK:- Outlets
    
    @IBOutlet weak var premiumIMG: UIImageView!
    @IBOutlet weak var imgFrame: UIImageView!
    @IBOutlet weak var btnFrames: UIButton!
    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var viewBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
