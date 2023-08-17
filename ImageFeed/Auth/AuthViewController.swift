import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    private let segueIdentifier = "ShowWebView"
    private let oAuth2Service = OAuth2Service()
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    
    weak var delegate: AuthViewControllerDelegate?
    
    @IBOutlet private weak var authButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authButton.layer.cornerRadius = 16
        authButton.layer.masksToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier,
           let webViewViewController = segue.destination as? WebViewViewController {
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

// MARK: Status Bar Style
extension AuthViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
