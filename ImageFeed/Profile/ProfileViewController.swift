import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preparatorySettings()

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func preparatorySettings() {
        profilePhoto.image = UIImage(named: "userPhoto")
        
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.textColor = .ypWhite
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        
        nicknameLabel.text = "@ekaterina_nov"
        nicknameLabel.textColor = .ypGray
        nicknameLabel.font = UIFont.systemFont(ofSize: 13)
        
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        
        let configuration = UIImage.SymbolConfiguration(scale: .large)
        logoutButton.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        logoutButton.tintColor = .ypRed
        let symbolName = "ipad.and.arrow.forward"
        let symbolImage = UIImage(systemName: symbolName)

        if let image = symbolImage {
            let configuration = UIImage.SymbolConfiguration(weight: .medium)
            let boldImage = image.withConfiguration(configuration)
            let button = UIButton(type: .system)
            logoutButton.setImage(boldImage, for: .normal)
        }
    }
    
    @IBAction func didTapLogoutButton(_ sender: UIButton) {
    }
    
    
    
    
}
