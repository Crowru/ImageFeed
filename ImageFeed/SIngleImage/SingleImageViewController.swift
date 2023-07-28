import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: URL?
    
    var imageDownload: UIImage?
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        loadAndShowImage(url: image)
    }

// MARK: Load and show image
    func loadAndShowImage(url: URL?) {
        guard let url else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                self.imageDownload = imageResult.image
            case .failure(let error):
                print(error.localizedDescription)
                self.showError(url: url)
            }
        }
    }
    
    @IBAction func didTapBackAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTabShareButton(_ sender: UIButton) {
        guard let image = self.imageDownload else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        share.overrideUserInterfaceStyle = .dark
        present(share, animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: Show error
extension SingleImageViewController {
    private func showError(url: URL) {
        let alert = UIAlertController(title: "Что-то пошло не так.", message: "Попробовать ещё раз?", preferredStyle: .alert)
        let repeats = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self else { return }
            self.loadAndShowImage(url: url)
        }
        let cancel = UIAlertAction(title: "Не надо", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(repeats)
        
        present(alert, animated: true)
    }
}

// MARK: Status Bar Style
extension SingleImageViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
