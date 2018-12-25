//
//  VenueTableViewCell.swift
//  Find Near
//
//  Created by Jiahe Kuang on 12/23/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import UIKit
import Kingfisher

class VenueTableViewCell: UITableViewCell {
    @IBOutlet weak var venueImageView: UIImageView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueAddressLabel: UILabel!
    @IBOutlet weak var venueRatingLabel: UILabel!
    
    func configure(for venue: Venue) {
        venueNameLabel.text = venue.name
        venueAddressLabel.text = venue.address
        venueRatingLabel.text = "\(venue.rating)"
        guard let photoUrl = URL(string: venue.photoUrl) else { return }
        venueImageView.kf.indicatorType = .activity
        let imageSource = ImageResource(downloadURL: photoUrl)
        venueImageView.kf.setImage(with: imageSource)
    }
}
