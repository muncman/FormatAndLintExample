//
//  ContentView.swift
//  FormatAndLintExample
//
//  Created by Kevin Munc on 5/9/22.
//

import SwiftUI

extension View {
    func viewPrint(_ vars: Any...) -> some View {
        _ = vars.map { print($0) }
        return EmptyView()
    }
}

struct ContentView: View {
    var body: some View {
        viewPrint("Environment: \(Bundle.envInfo)") // large!
        List {
            BuildInfo()
            GitInfo()
            ToolInfo()
            HStack {
                Text("Host info:")
                Spacer()
                Text("\(Bundle.hostInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BuildInfo: View {
    var body: some View {
        HStack {
            Text("UTC build time:")
            Spacer()
            Text("\(Bundle.buildTime)")
        }
        HStack {
            Text("UTC build date:")
            Spacer()
            Text("\(Bundle.buildDate)")
        }
        HStack {
            Text("Build number:")
            Spacer()
            Text("\(Bundle.buildNumber)")
        }
        HStack {
            Text("Version number:")
            Spacer()
            Text("\(Bundle.marketingVersion)")
        }
    }
}

struct GitInfo: View {
    var body: some View {
        HStack {
            Text("Git commit count:")
            Spacer()
            Text("\(Bundle.gitCommitCount)")
        }
        HStack {
            Text("Git branch:")
            Spacer()
            Text("\(Bundle.gitBranch)")
        }
        HStack {
            Text("Git SHA:")
            Spacer()
            Text("\(Bundle.gitSha)")
        }
    }
}

struct ToolInfo: View {
    var body: some View {
        HStack {
            Text("xcodebuild version:")
            Spacer()
            Text("\(Bundle.xcodeBuildVersion)")
        }
        HStack {
            Text("xcode-select version:")
            Spacer()
            Text("\(Bundle.xcodeSelectVersion)")
        }
        HStack {
            Text("xcrun version:")
            Spacer()
            Text("\(Bundle.xcrunVersion)")
        }
        HStack {
            Text("Clang version:")
            Spacer()
            Text("\(Bundle.clangVersion)")
        }
    }
}
