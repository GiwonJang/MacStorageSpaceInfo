//
//  AppDelegate.swift
//  MacStorageSpaceInfoLauncher
//
//  Created by JANGGIWON on Jun 14, 2016.
//  Copyright © 2016 Handicraft. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let mainAppIdentifier = "io.handicraft.MacStorageSpaceInfo"
		let running           = NSWorkspace.shared.runningApplications
		var alreadyRunning    = false

		for app in running {
			if app.bundleIdentifier == mainAppIdentifier {
				alreadyRunning = true
				break
			}
		}

		if !alreadyRunning {
            DistributedNotificationCenter.default.addObserver(self, selector: #selector(Process.terminate), name: NSNotification.Name("killme"), object: mainAppIdentifier)

			let path = Bundle.main.bundlePath as NSString
			var components = path.pathComponents
			components.removeLast()
			components.removeLast()
			components.removeLast()
			components.append("MacOS")
			components.append("MacStorageSpaceInfo") //main app name

			let newPath = NSString.path(withComponents: components)

			NSWorkspace.shared.launchApplication(newPath)
		} else {
			self.terminate()
		}

	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func terminate() {
		NSApp.terminate(nil)
	}

}
