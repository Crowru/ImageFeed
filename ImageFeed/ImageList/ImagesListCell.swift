import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageCell: UIImageView!
}

extension ImagesListCell {
    final func configure(image: UIImage, date: String, isLiked: Bool) {
        imageCell.image = image
        dateLabel.text = date
        let likeImage = isLiked ? UIImage(named: "likeOn") : UIImage(named: "likeOff")
        likeButton.setImage(likeImage, for: .normal)
    }
}
