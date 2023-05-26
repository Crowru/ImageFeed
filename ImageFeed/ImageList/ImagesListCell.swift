import UIKit

class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageCell: UIImageView!
}
