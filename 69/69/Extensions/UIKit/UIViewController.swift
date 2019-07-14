//
//  UIViewController.swift
//  69
//
//  Created by Vlados iOS on 7/14/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import UIKit

extension UIViewController {
    static func instanceFromStoryboard(_ storyboard: UIStoryboard) -> UIViewController {
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}
