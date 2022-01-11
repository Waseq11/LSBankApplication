//  Kani - P. H. Otero - 2015233
//
//  TransactionTableViewCell.swift
//  IOS-FinalProject-LSBank
//
//  Created by english on 2021-11-24.
//

import UIKit

class TransactionTableViewCell: UITableViewCell
{
    //creating an identifier to avoid mistakes when handling the name for this cell
    static let identifier = "TransactionTableViewCell"

    
    @IBOutlet weak var lblAccountHolder: UILabel!
    
    @IBOutlet weak var imgType: UIImageView!
    
    @IBOutlet weak var lblAmount: UILabel!
    
    @IBOutlet weak var lblMessage: UILabel!
    
    @IBOutlet weak var lblDateAndTime: UILabel!
    
    
    static func nib() -> UINib
    {
        return UINib(nibName: identifier, bundle: nil)
    }

    
    public func setCellContent(holder : String, dateAndTime : String, amount : Double, credit : Bool = true, message : String = "")
    {
        
        var toFrom = ""
        
        // whether the user is receiving or sending money, the label will change and so will the arrow's color to point out the type of transaction
        if (credit == true)
        {
            toFrom = "FROM"
            imgType.image = UIImage(systemName: "arrow.down")
            imgType.tintColor = UIColor.systemGreen
        }
        else
        {
            toFrom = "TO"
            imgType.image = UIImage(systemName: "arrow.up")
            imgType.tintColor = UIColor.systemRed
        }
    
        lblAccountHolder.text = "\(toFrom) \(holder)"
        lblAmount.text = amount.formatAsCurrency()
        lblDateAndTime.text = dateAndTime
    
        
        // if there is a message it will be displayed, else, it will be hiddn by default
        if message.count == 0
        {
            lblMessage.isHidden = true
        }
        else
        {
            lblMessage.text = message
            lblMessage.isHidden = false
        }
    }
        

    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
