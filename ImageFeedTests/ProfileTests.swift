//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Руслан  on 13.08.2023.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    
    private struct ProfileServiceStub: ProfileServiceProtocol {
        var profile: ImageFeed.ProfileResult? = ProfileResult(username: "test", firstName: "test", lastName: "test", bio: "test")
        
        func fetchProfile(_ token: String, completion: @escaping (Result<ImageFeed.ProfileResult, Error>) -> Void) {}
    }
    
    private struct ProfileImageServiceStub: ProfileImageServiceProtocol {
        var avatarURL: String? = "https://api.unsplash.com"
        
        func fetchProfileImageURL(_ username: String, completion: @escaping (Result<String, Error>) -> Void) {}
    }
    
    func testUpdataProfileDetailsCalls() {
        //given
        let viewController = ProfileViewController()
        let spyPresenter = ProfileViewPresentSpy()
        viewController.presenter = spyPresenter
        spyPresenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(spyPresenter.updateProfileDetailsCalled)
    }
    
    func testViewControllerProfileDetailsCalls() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profileServiceStub = ProfileServiceStub()
        let profileImageServiceStub = ProfileImageServiceStub()
        let presenter = ProfileViewPresenter(profileService: profileServiceStub,
                                             profileImageService: profileImageServiceStub)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.updateProfileDetails()
        
        //then
        XCTAssertTrue(viewController.setupProfileDetailsCalled)
        XCTAssertTrue(viewController.setupAvatarCalled)
    }
}

// MARK: Spy Objects
final class ProfileViewPresentSpy: ProfileViewPresenterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?
    
    var updateAvatarCalled = false
    var updateProfileDetailsCalled = false
    
    func updateProfileDetails() {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func observerProfileImageService() {
    }
  
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    var setupProfileDetailsCalled = false
    var setupAvatarCalled = false
    func setupProfileDetails(name: String, login: String, bio: String) {
        setupProfileDetailsCalled = true
    }
    
    func setupAvatar(url: URL) {
        setupAvatarCalled = true
    }
}
