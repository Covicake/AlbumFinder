//
//  AlbumListCell.swift
//  AlbumFinder2
//
//  Created by Fernando García Hernández on 9/3/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.
//

import UIKit
//Celda de TableView para mostrar una lista de álbumes.
class AlbumListCell: UITableViewCell {  //Una celda personalizada para el table view. Contiene una imagen y 3 campos de texto.

    @IBOutlet weak var cellimageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var yearLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
