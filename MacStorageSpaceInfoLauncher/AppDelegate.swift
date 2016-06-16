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



	func applicationDidFinishLaunching(aNotification: NSNotification) {
		let mainAppIdentifier = "io.handicraft.MacStorageSpaceInfo"
		let running           = NSWorkspace.sharedWorkspace().runningApplications
		var alreadyRunning    = false

		for app in running {
			if app.bundleIdentifier == mainAppIdentifier {
				alreadyRunning = true
				break
			}
		}

		if !alreadyRunning {
			NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: "terminate", name: "killme", object: mainAppIdentifier)

			let path = NSBundle.mainBundle().bundlePath as NSString
			var components = path.pathComponents
			components.removeLast()
			components.removeLast()
			components.removeLast()
			components.append("MacOS")
			components.append("MacStorageSpaceInfo") //main app name

			let newPath = NSString.pathWithComponents(components)

			NSWorkspace.sharedWorkspace().launchApplication(newPath)
		} else {
			self.terminate()
		}

	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	func terminate() {
		NSApp.terminate(nil)
	}

}
