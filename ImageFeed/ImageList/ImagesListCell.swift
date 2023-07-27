import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageCell: UIImageView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    func setupCell(from photo: Photo) {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        
        let url = URL(string: photo.smallImageURL)
        imageCell.kf.indicatorType = .activity
        imageCell.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceholder")) { result in
            switch result {
            case .success(let image):
                self.imageCell.contentMode = .scaleToFill
                self.imageCell.image = image.image
            case .failure(let error):
                print("Ошибка загрузки картинки: \(error)")
                self.imageCell.image = UIImage(named: "ImagePlaceholder")
            }
        }
        dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
                  
        
    }
}

extension ImagesListCell {
    final func configure(image: UIImage, date: String, isLiked: Bool) {
        imageCell.image = image
        dateLabel.text = date
        let likeImage = isLiked ? UIImage(named: "likeOn") : UIImage(named: "likeOff")
        likeButton.setImage(likeImage, for: .normal)
    }
}
