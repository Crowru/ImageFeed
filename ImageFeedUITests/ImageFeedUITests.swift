//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Руслан  on 16.08.2023.
//

@testable import ImageFeed
import XCTest

final class ImageFeedUITests: XCTestCase {

    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["AuthenticateButton"].tap()

        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("ruslanusmanov7779@gmail.com")
        let doneButton = app.buttons["Done"]
        doneButton.tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("zxcvbnmO1!")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        print(app.debugDescription)
    }
    
    func testFeed() throws {
        sleep(3)
        let tableQuery = app.tables
        
        let cell = tableQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tableQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["likeOff"].tap()
        cellToLike.buttons["likeOn"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 20))
        image.pinch(withScale: 3, velocity: 1)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        image.pinch(withScale: 0.5, velocity: -1)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        let singleImageBackButton = app.buttons["singleImageBackButton"]
        singleImageBackButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        let tabBars = app.tabBars
        let button = tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()
        sleep(3)
        XCTAssertTrue(app.staticTexts["nameLabel"].exists)
        XCTAssertTrue(app.staticTexts["nicknameLabel"].exists)
        
        app.buttons["logout"].tap()
        sleep(2)
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        sleep(2)
        XCTAssertTrue(app.buttons["AuthenticateButton"].exists)
    }
}
