//
//  Int.swift
//  BSDRandom
//
//  Created by 전건우 on 06/05/2019.
//  Copyright © 2019 geonu. All rights reserved.
//

import Foundation

extension Int {
    static func randoms(lessThan cases: Int, number: Int) -> [Int] {
        var randoms: Set<Int> = []
        
        for _ in 0 ..< number {
            var random = Int.random(in: 0 ..< cases)
            while true {
                if randoms.contains(random) {
                    random = (random + 1) % cases
                }
                else {
                    randoms.insert(random)
                    break
                }
            }
        }
        
        return randoms.sorted()
    }
}
