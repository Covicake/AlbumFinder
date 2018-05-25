//
//  DetailTableViewCell.swift
//  AlbumFinder2
//
//  Created by Fernando García Hernández on 12/3/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.
//

import UIKit
//Celda de TableView para mostrar los detalles de un álbum.
class DetailTableViewCell: UITableViewCell {  //Celda personalizada para un tableView. Contiene dos campos de texto.

    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackDurationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
