import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    var presenter: ImagesListPresenterProtocol? = {
        return ImagesListPresenter()
    }()
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.view = self
        setupTableView()
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath else {
            super.prepare(for: segue, sender: sender)
            return
        }
        guard let photo = presenter?.getPhotoIndex(indexPath.row)?.largeImageURL else { return }
        let largeImageURL = URL(string: photo)
        viewController.image = largeImageURL
    }
    
    // MARK: Update Table View Animated
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
        
    }
    
    // MARK: Table View
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

// MARK: Table View Data Source
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let photosCount = presenter?.photosCount else { return 0 }
        return photosCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        
        setupCell(imageListCell, indexPath)
        return imageListCell
    }
    
    private func setupCell(_ cell: ImagesListCell, _ indexPath: IndexPath) {
        guard let photo = presenter?.getPhotoIndex(indexPath.row) else { return }
        cell.setupCell(from: photo)
    }
}

// MARK: Table View Delegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplay(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.getPhotoIndex(indexPath.row)?.size else { return CGFloat() }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

// MARK: - Images List Cell Delegate
extension ImagesListViewController: ImagesListDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.imageListCellDidTapLike(indexPath.row, cell)
    }
}

// MARK: - Status Bar Style
extension ImagesListViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
