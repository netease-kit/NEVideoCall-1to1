// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import UIKit

class NEBundleUtils {
  static func getBundleImage(name: String) -> UIImage? {
    print("NEBundleUtils: Attempting to load image '\(name)'")

    // 方法1：直接从当前 Bundle 的 Assets 中加载
    if let image = UIImage(named: name) {
      print("NEBundleUtils: Successfully loaded '\(name)' from main bundle")
      return image
    }

    // 方法2：从当前 Bundle 的 Assets 中加载（指定 Bundle）
    if let image = UIImage(named: name, in: Bundle.main, compatibleWith: nil) {
      print("NEBundleUtils: Successfully loaded '\(name)' from main bundle with explicit bundle")
      return image
    }

    // 方法3：尝试从当前类的 Bundle 中加载
    let bundle = Bundle(for: NEBundleUtils.self)
    print("NEBundleUtils: Current class bundle path: \(bundle.bundlePath)")
    if let image = UIImage(named: name, in: bundle, compatibleWith: nil) {
      print("NEBundleUtils: Successfully loaded '\(name)' from class bundle")
      return image
    }

    // 方法4：尝试从 NECallKitBundle.bundle 中加载（如果存在）
    if let bundleURL = Bundle.main.url(forResource: "NECallKitBundle", withExtension: "bundle") {
      print("NEBundleUtils: Found NECallKitBundle at: \(bundleURL)")
      if let bundle = Bundle(url: bundleURL),
         let image = UIImage(named: name, in: bundle, compatibleWith: nil) {
        print("NEBundleUtils: Successfully loaded '\(name)' from NECallKitBundle")
        return image
      }
    } else {
      print("NEBundleUtils: NECallKitBundle not found in main bundle")
    }

    // 方法5：尝试从所有可用的 Bundle 中搜索
    let allBundles = Bundle.allBundles
    for bundle in allBundles {
      if let image = UIImage(named: name, in: bundle, compatibleWith: nil) {
        print("NEBundleUtils: Successfully loaded '\(name)' from bundle: \(bundle.bundleIdentifier ?? bundle.bundlePath)")
        return image
      }
    }

    print("NEBundleUtils: Failed to load image named '\(name)' from any available bundle")
    print("NEBundleUtils: Available bundles:")
    for bundle in Bundle.allBundles {
      print("  - \(bundle.bundleIdentifier ?? bundle.bundlePath)")
    }
    return nil
  }
}
