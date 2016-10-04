//
//  AspectFitSizeFunctionTest.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import XCTest
@testable import ImageViewer

/*
We are testing what is the fitting size of an image on phone's screen. We have these combinations:

Phone - portrait (no need for landscape as tests are geometrically symetrical)
Image - portrait, landscape, square ie.e both sides smaller, one side larger, both sides larger
sizes identical

*/

class AspectFitSizeFunctionTest: XCTestCase {
    
    let portraitScreenSize  = CGSize(width: 320, height: 480)
    
    func test_ImageSizeIdenticalToScreen() {
        
        let imageSize       = CGSize(width: 320, height: 480)
        let expectedSize    = CGSize(width: 320, height: 480)
        let aspectFitSize   = aspectFitContentSize(forBoundingSize: portraitScreenSize, contentSize: imageSize)
        
        XCTAssertEqual(expectedSize, aspectFitSize)
    }
    
    func test_SquareImage_BothSidesSmaller_onPortraitScreen() {
        
        let imageSize       = CGSize(width: 160, height: 160)
        let expectedSize    = CGSize(width: 320, height: 320)
        let aspectFitSize   = aspectFitContentSize(forBoundingSize: portraitScreenSize, contentSize: imageSize)
        
        XCTAssertEqual(expectedSize, aspectFitSize)
    }
    
    func test_SquareImage_BothSidesLarger_onPortraitScreen() {
        
        let imageSize       = CGSize(width: 960, height: 960)
        let expectedSize    = CGSize(width: 320, height: 320)
        let aspectFitSize   = aspectFitContentSize(forBoundingSize: portraitScreenSize, contentSize: imageSize)
        
        XCTAssertEqual(expectedSize, aspectFitSize)
    }
    
    func test_SquareImage_matchesWidth_onPortraitScreen() {
        
        let imageSize       = CGSize(width: 320, height: 320)
        let expectedSize    = CGSize(width: 320, height: 320)
        let aspectFitSize   = aspectFitContentSize(forBoundingSize: portraitScreenSize, contentSize: imageSize)
        
        XCTAssertEqual(expectedSize, aspectFitSize)
    }
    
    func test_SquareImage_MatchesHeight_onPortraitScreen() {
        
        let imageSize       = CGSize(width: 480, height: 480)
        let expectedSize    = CGSize(width: 320, height: 320)
        let aspectFitSize   = aspectFitContentSize(forBoundingSize: portraitScreenSize, contentSize: imageSize)
        
        XCTAssertEqual(expectedSize, aspectFitSize)
    }
    
    func test_LandscapeImage_BothSidesSmaller_onPortraitScreen() {
        
        let imageSize       = CGSize(width: 160, height: 120)
        let expectedSize    = CGSize(width: 320, height: 240)
        let aspectFitSize   = aspectFitContentSize(forBoundingSize: portraitScreenSize, contentSize: imageSize)
        
        XCTAssertEqual(expectedSize, aspectFitSize)
    }
    
    func test_LandscapeImage_BothSidesLarger_onPortraitScreen() {
        
        let imageSize       = CGSize(width: 960, height: 720)
        let expectedSize    = CGSize(width: 320, height: 240)
        let aspectFitSize   = aspectFitContentSize(forBoundingSize: portraitScreenSize, contentSize: imageSize)
        
        XCTAssertEqual(expectedSize, aspectFitSize)
    }
    
    func test_LandscapeImage_horizontalyLarger_onPortraitScreen() {
        
        let imageSize       = CGSize(width: 800, height: 600)
        let expectedSize    = CGSize(width: 320, height: 240)
        let aspectFitSize   = aspectFitContentSize(forBoundingSize: portraitScreenSize, contentSize: imageSize)
        
        XCTAssertEqual(expectedSize, aspectFitSize)
    }
    
    func test_PotraitImage_BothSidesSmaller_onPortraitScreen() {
        
        let imageSize       = CGSize(width: 160, height: 200)
        let expectedSize    = CGSize(width: 320, height: 400)
        let aspectFitSize   = aspectFitContentSize(forBoundingSize: portraitScreenSize, contentSize: imageSize)
        
        XCTAssertEqual(expectedSize, aspectFitSize)
    }
    
    func test_PotraitImage_BothSidesLarger_onPortraitScreen() {
        
        let imageSize       = CGSize(width: 480, height: 960)
        let expectedSize    = CGSize(width: 240, height: 480)
        let aspectFitSize   = aspectFitContentSize(forBoundingSize: portraitScreenSize, contentSize: imageSize)
        
        XCTAssertEqual(expectedSize, aspectFitSize)
    }
    
    func test_PotraitImage_VerticalyLarger_onPortraitScreen() {
        
        let imageSize       = CGSize(width: 320, height: 600)
        let expectedSize    = CGSize(width: 256, height: 480)
        let aspectFitSize   = aspectFitContentSize(forBoundingSize: portraitScreenSize, contentSize: imageSize)
        
        XCTAssertEqual(expectedSize, aspectFitSize)
    }
}
