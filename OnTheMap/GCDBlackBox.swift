//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Lisue She on 5/29/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
