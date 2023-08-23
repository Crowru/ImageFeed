import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func setupProfileDetails(name: String, login: String, bio: String)
    func setupAvatar(url: URL)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    private let avatarPlaceHolder = UIImage(named: "placeholder")
    private let profileService = ProfileService.shared
    
    private let profilePhoto: UIImageView = {
        let image = UIImage(named: "placeholder")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "nameLabel"
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaerina_nov"
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "nicknameLabel"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let gradientLayer = GradientLayer.share
    
    var presenter: ProfileViewPresenterProtocol? = {
        return ProfileViewPresenter()
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "ipad.and.arrow.forward")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        button.accessibilityIdentifier = "logout"
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupViews()
        setupAllConstraints()
        
        presenter?.view = self
        presenter?.updateProfileDetails()
        presenter?.observerProfileImageService()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gradientLayer.gradientLayer(view: profilePhoto, width: 70, height: 70, cornerRadius: 35)
        gradientLayer.gradientLayer(view: nameLabel, width: nameLabel.intrinsicContentSize.width, height: nameLabel.intrinsicContentSize.height, cornerRadius: 10)
        gradientLayer.gradientLayer(view: nicknameLabel, width: nicknameLabel.intrinsicContentSize.width, height: nicknameLabel.intrinsicContentSize.height, cornerRadius: 5)
        gradientLayer.gradientLayer(view: descriptionLabel, width: (descriptionLabel.intrinsicContentSize.width <= 366) ? descriptionLabel.intrinsicContentSize.width : 366, height: descriptionLabel.intrinsicContentSize.height, cornerRadius: 5)
    }
    
    func setupProfileDetails(name: String, login: String, bio: String) {
        nameLabel.text = name
        nicknameLabel.text = login
        descriptionLabel.text = bio
    }
    
    func setupAvatar(url: URL) {
        let cache = ImageCache.default
        cache.clearDiskCache()
        cache.clearMemoryCache()
        let processor = RoundCornerImageProcessor(cornerRadius: 42)
        
        profilePhoto.kf.indicatorType = IndicatorType.activity
        profilePhoto.kf.setImage(with: url, placeholder: avatarPlaceHolder, options: [.processor(processor), .transition(.fade(1))]) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let image):
                self.profilePhoto.image = image.image
                self.gradientLayer.removeFromSuperLayer(views: [self.profilePhoto, self.nameLabel, self.nicknameLabel, self.descriptionLabel, self.logoutButton])
            case .failure(let error):
                print("failed to upload avatar \(error)")
            }
        }
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        
        let cache = ImageCache.default
        cache.clearDiskCache()
        let processor = RoundCornerImageProcessor(cornerRadius: 42)
        
        profilePhoto.kf.setImage(with: url,
                                 placeholder: UIImage(named: "placeholder"),
                                 options: [.processor(processor), .transition(.fade(1))])
    }
    
    private func setupViews() {
        view.addSubview(profilePhoto)
        view.addSubview(nameLabel)
        view.addSubview(nicknameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupAllConstraints() {
        NSLayoutConstraint.activate([
            profilePhoto.heightAnchor.constraint(equalToConstant: 70),
            profilePhoto.widthAnchor.constraint(equalToConstant: 70),
            profilePhoto.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profilePhoto.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            
            nameLabel.topAnchor.constraint(equalTo: profilePhoto.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nicknameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            logoutButton.centerYAnchor.constraint(equalTo: profilePhoto.centerYAnchor)
        ])
    }
    
    @objc
    private func didTapLogoutButton() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            OAuth2TokenStorage.shared.clean()
            WebViewViewController.clean()
            ImagesListCell.clean()
            
            guard let window = UIApplication.shared.windows.first else {
                fatalError("invalid configuration")
            }
            window.rootViewController = SplashViewController()
            window.makeKeyAndVisible()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
    }
}

// MARK: Update Profile Details
private extension ProfileViewController {
    func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        nameLabel.text = "\(profile.firstName) \(profile.lastName ?? "")"
        nicknameLabel.text = "@\(profile.username)"
        descriptionLabel.text = profile.bio
    }
}

// MARK: - Status Bar Style
extension ProfileViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
