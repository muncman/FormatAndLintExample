//
//  VersionHelper.swift
//
//  Copyright (c) 2015 Method Up LLC. All rights reserved.
//

import Foundation

/**
 * Simple helper for the various parts of version information for a given build.
 *
 * Collected right before compilation.
 */
extension Bundle {
    static let buildNumber: String = infoDictionaryValueFor(key: "CFBundleVersion")

    static let marketingVersion: String = infoDictionaryValueFor(key: "CFBundleShortVersionString")

    static let buildDate: String = infoDictionaryValueFor(key: "XKEY_UTC_BUILD_DATE")

    static let buildTime: String = infoDictionaryValueFor(key: "XKEY_UTC_BUILD_TIME")

    static let gitSha: String = infoDictionaryValueFor(key: "XKEY_GIT_HASH")

    static let gitBranch: String = infoDictionaryValueFor(key: "XKEY_GIT_BRANCH")

    static let gitCommitCount: String = infoDictionaryValueFor(key: "XKEY_GIT_COMMIT_COUNT")

    static let xcodeBuildVersion: String = infoDictionaryValueFor(key: "XKEY_XCODE_BUILD_VERSION")

    static let xcodeSelectVersion: String = infoDictionaryValueFor(key: "XKEY_XCODE_SELECT_VERSION")

    static let xcrunVersion: String = infoDictionaryValueFor(key: "XKEY_XCRUN_VERSION")

    static let clangVersion: String = infoDictionaryValueFor(key: "XKEY_CLANG_VERSION")

    static let pkgutilInfo: String = infoDictionaryValueFor(key: "XKEY_PKGUTIL_INFO")

    static let hostInfo: String = infoDictionaryValueFor(key: "XKEY_UNAME_INFO")

    static let envInfo: String = infoDictionaryValueFor(key: "XKEY_ENV_INFO")
}

private func infoDictionaryValueFor(key: String) -> String {
    // swiftlint:disable force_cast
    (Bundle.main.infoDictionary![key] ?? "") as! String
    // swiftlint:enable force_cast
}
