//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Kevin Reese on 4/22/17.
//  Copyright © 2017 Kevin Reese. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var statusWheel: UIActivityIndicatorView!
    
    
    var taskToCancelifCellIsReused: URLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
    /*
    
    var loading: Bool {
        set {
            if newValue {
                photoImage.image = nil
                statusWheel.startAnimating()
                statusWheel.isHidden = false
            }
            else {
                statusWheel.stopAnimating()
                statusWheel.isHidden = true
            }
        }
        get {
            return !statusWheel.isHidden
        }
    }
 */
  /*
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        if photoImage.image == nil {
            statusWheel.isHidden = false
            statusWheel.startAnimating()
        }
    }
 }*/
}
