//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Руслан  on 15.08.2023.
//

@testable import ImageFeed
import XCTest

final class ImageListTests: XCTestCase {
    
    func testFetchPhotosNextPage() {
        //given
        let imageListServiceTestModel = ImageListServiceTestModel()
        let presenter = ImagesListPresenter(imagesListService: imageListServiceTestModel)
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertEqual(imageListServiceTestModel.photos.count, 1)
    }
    
    func testUpdateTableView() {
        // given
        let ImageListServiceTestModel = ImageListServiceTestModel()
        let view = ImageListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesListService: ImageListServiceTestModel)
        presenter.view = view

        // when
        ImageListServiceTestModel.fetchPhotosNextPage()
        presenter.updateTableView()

        // then
        XCTAssertTrue(view.updateTableViewAnimatedCalled == true)
    }
    
    func testWillDisplay() {
        // given
        let ImageListServiceTestModel = ImageListServiceTestModel()
        let view = ImageListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesListService: ImageListServiceTestModel)
        presenter.view = view

        // when
        ImageListServiceTestModel.fetchPhotosNextPage()
        presenter.updateTableView()
        presenter.willDisplay(0)

        // then
        XCTAssertEqual(ImageListServiceTestModel.photos.count, 2)
    }
}

// MARK: Image List Service Test Model
private let dateFormatter = ISO8601DateFormatter()
private let photo = Photo(PhotoResult(id: "test",
                                      width: 100,
                                      height: 100,
                                      createdAt: "2022-10-12T01:11:34",
                                      description: "test",
                                      urls: UrlsResult(full: "test",
                                                       regular: "test",
                                                       small: "test",
                                                       thumb: "test"),
                                      likedByUser: false),
                                      date: dateFormatter)

private final class ImageListServiceTestModel: ImagesListServiceProtocol {
    var photos: [ImageFeed.Photo] = []
    func fetchPhotosNextPage() { photos.append(photo) }
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {}
}

// MARK: Spy Objects
final class ImageListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImageFeed.ImagesListViewControllerProtocol?
    var photosCount: Int = 0
    
    var viewDidLoadCalled = false
    var getPhotoIndexCalled = false
    var tableViewUpdatedCalled = false
    var willDisplayCalled = false
    var imageListCellDidTapLikeCalled = false
    
    func getPhotoIndex(_ index: Int) -> ImageFeed.Photo? {
        getPhotoIndexCalled = true
        return nil
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateTableView() {
        tableViewUpdatedCalled = true
    }
    
    func willDisplay(_ indexPath: Int) {
        willDisplayCalled = true
    }
    
    func imageListCellDidTapLike(_ index: Int, _ cell: ImageFeed.ImagesListCell) {
        imageListCellDidTapLikeCalled = true
    }
}

final class ImageListViewControllerSpy : ImagesListViewControllerProtocol {
    var presenter: ImageFeed.ImagesListPresenterProtocol?
    var updateTableViewAnimatedCalled = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
}
