//
//  AppDelegate.swift
//  MacStorageSpaceInfo
//
//  Created by JANGGIWON on May 17, 2016.
//  Copyright © 2016 Handicraft. All rights reserved.
//

import Cocoa
import CleanroomLogger
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!

	@IBOutlet weak var statusMenu: NSMenu!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

	var refreshTimer: Timer!

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let launcherAppIdentifier = "io.handicraft.MacStorageSpaceInfoLauncher"

		//you should move this next line to somewhere else this is for testing purposes only!!!
		SMLoginItemSetEnabled(launcherAppIdentifier as CFString, true)

		var startedAtLogin = false
		for app in NSWorkspace.shared.runningApplications {
			if app.bundleIdentifier == launcherAppIdentifier {
				startedAtLogin = true
			}
		}

		if startedAtLogin {
            DistributedNotificationCenter.default.post(name: NSNotification.Name("killme"), object: Bundle.main.bundleIdentifier)
		}


		// Init CleanroomLogger
		//Log.enable(configuration: XcodeLogConfiguration())
        Log.enable(minimumSeverity: .info,
                   debugMode: false,
                   verboseDebugMode: false,
                   stdStreamsMode: .useAsFallback,
                   mimicOSLogOutput: true,
                   showCallSite: true,
                   filters: [])

		//let icon = NSImage(named: "statusIcon")
		//icon?.template = true

		//statusItem.image = icon
		statusItem.menu = statusMenu
		//statusItem.title = "test"

		startRefreshTimer()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		refreshTimer.invalidate()
		Log.debug?.message("Refresh Timer Stopped.")
	}

	@IBAction func menuClicked(_ sender: NSMenuItem) {
		let task = Process()
		task.launchPath = "/usr/bin/defaults"

		if (sender.state == .on) {
			sender.state = .off
			task.arguments = ["write", "com.apple.finder", "AppleShowAllFiles", "NO"]
		} else {
			sender.state = .on
			task.arguments = ["write", "com.apple.finder", "AppleShowAllFiles", "YES"]
		}

		task.launch()
		task.waitUntilExit()

		let killtask = Process()
		killtask.launchPath = "/usr/bin/killall"
		killtask.arguments = ["Finder"]
		killtask.launch()
	}

	@IBAction func quitClicked(_ sender: NSMenuItem) {
		NSApplication.shared.terminate(self)
	}

	func deviceRemainingFreeSpaceInBytes() -> Double? {
		let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectoryPath.last!) {
			if let freeSize = systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber {
				let freeSizeInGB = Double(freeSize.int64Value) / 1073741824.0
				//NSLog("\(freeSizeInGB)")
				return freeSizeInGB
			}
		}

		return nil
	}

	func startRefreshTimer() {
		refreshTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(AppDelegate.update), userInfo: nil, repeats: true)
		RunLoop.main.add(refreshTimer, forMode: RunLoopMode.commonModes)
		Log.debug?.message("Refresh Timer Started.")
	}

    @objc func update() {
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
