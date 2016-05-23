//
//  AppDelegate.swift
//  MacStorageSpaceInfo
//
//  Created by JANGGIWON on May 17, 2016.
//  Copyright © 2016 Handicraft. All rights reserved.
//

import Cocoa
import CleanroomLogger

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!

	@IBOutlet weak var statusMenu: NSMenu!

	let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

	var refreshTimer: NSTimer!

	func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Init CleanroomLogger
        //Log.enable(configuration: XcodeLogConfiguration())
        Log.enable(minimumSeverity: .Info,
                   debugMode: true,
                   verboseDebugMode: false,
                   timestampStyle: .Default,
                   severityStyle: .Xcode,
                   showCallSite: true,
                   showCallingThread: false,
                   suppressColors: false,
                   filters: [])

		//let icon = NSImage(named: "statusIcon")
		//icon?.template = true

		//statusItem.image = icon
		statusItem.menu = statusMenu
		//statusItem.title = "test"

		startRefreshTimer()
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		refreshTimer.invalidate()
        Log.debug?.message("Refresh Timer Stopped.")
	}

	@IBAction func menuClicked(sender: NSMenuItem) {
		let task = NSTask()
		task.launchPath = "/usr/bin/defaults"

		if (sender.state == NSOnState) {
			sender.state = NSOffState
			task.arguments = ["write", "com.apple.finder", "AppleShowAllFiles", "NO"]
		} else {
			sender.state = NSOnState
			task.arguments = ["write", "com.apple.finder", "AppleShowAllFiles", "YES"]
		}

		task.launch()
		task.waitUntilExit()

		let killtask = NSTask()
		killtask.launchPath = "/usr/bin/killall"
		killtask.arguments = ["Finder"]
		killtask.launch()
	}

	@IBAction func quitClicked(sender: NSMenuItem) {
		NSApplication.sharedApplication().terminate(self)
	}

	func deviceRemainingFreeSpaceInBytes() -> Double? {
		let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		if let systemAttributes = try? NSFileManager.defaultManager().attributesOfFileSystemForPath(documentDirectoryPath.last!) {
			if let freeSize = systemAttributes[NSFileSystemFreeSize] as? NSNumber {
				let freeSizeInGB = Double(freeSize.longLongValue) / 1073741824.0
				//NSLog("\(freeSizeInGB)")
				return freeSizeInGB
			}
		}

		return nil
	}

	func startRefreshTimer() {
		refreshTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(AppDelegate.update), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(refreshTimer, forMode: NSRunLoopCommonModes)
        Log.debug?.message("Refresh Timer Started.")
	}

	func update() {
		let freeSizeInGB = deviceRemainingFreeSpaceInBytes()!
		let numberOfPlaces = 2.0
		let multiplier = pow(10.0, numberOfPlaces)
		let spaceString = "\(round(freeSizeInGB * multiplier) / multiplier)GB"

		statusItem.button!.title = spaceString
		//statusItem.length = measureTextLength(spaceString).toIntMax()
	}

	/*func measureTextLength(text: String) -> Int {
		let myString: NSString = text as NSString
		let size: CGSize = myString.sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(14.0)])
		return Int(size.width)
	}*/
}
