//
//  XCTBlockExpectation.swift
//  MyTravelHelperTests
//
//  Created by pcadmin on 07/06/21.
//  Copyright © 2021 Sample. All rights reserved.
//

import XCTest

/// `XCTBlockExpectation` is fulfilled *immediately* when the block condition is met,
/// rather than taking a full second to fulfill like `XCTNSPredicateExpectation`.
class XCTBlockExpectation: XCTestExpectation {
    /// The `DispatchQueue` where the block will run until it returns true.
    private var queue = DispatchQueue(label: "XCTBlockExpectationQueue", qos: .background)
    
    /// Initializes an `XCTBlockExpectation` with the given block.
    /// - parameter condition: The block that is evaluated by the expectation.
    init(condition: @escaping () -> Bool) {
        super.init(description: "XCTBlockExpectation")
        waitForCondition(condition: condition)
    }
    
    /// Continually evaluate the condition block until it returns true, fulfilling this expectation.
    /// - parameter condition: The block that is evaluated by the expectation.
    private func waitForCondition(condition: @escaping () -> Bool) {
        queue.async { [weak self] in
            if condition() {
                self?.fulfill()
            } else {
                self?.waitForCondition(condition: condition)
            }
        }
    }
}
