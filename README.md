# Table of Contents
**[Installation](https://github.com/sofianetchek/sample_ios_sdk/blob/main/README.md#installation)**<br><br>
**[Prerequisites](https://github.com/sofianetchek/sample_ios_sdk/blob/main/README.md#prerequisites)**<br><br>
**[Usage](https://github.com/sofianetchek/sample_ios_sdk/blob/main/README.md#usage)**<br><br>
**[Documentation](https://github.com/sofianetchek/sample_ios_sdk/blob/main/README.md#complete-documentation)**<br>
_________________
# Installation

1. From Finder Copy / Paste the TchekSDK.xcframework into your Xcode project folder

![](https://github.com/sofianetchek/sample_ios_sdk/blob/main/Screenshots/Install_1.png?raw=true "")

2. Inside your project, select your target and drag and drop the TchekSDK.xcframework into Framework, Librairies and Embedded Content

![](https://github.com/sofianetchek/sample_ios_sdk/blob/main/Screenshots/Install_2.png?raw=true "")

# Prerequisites
Due to usage of camera, add key `Privacy - Camera Usage Description` in your Info.plist

![](https://github.com/sofianetchek/sample_ios_sdk/blob/main/Screenshots/Install_3.png?raw=true "")

# Usage
*Important: The key used in the documentation and the sample is very limited key, you must use yours to fully use the TchekSDK.*

In order to use the TchekSdk, you must first call the `configure()` method as follows
```
let builder = TchekBuilder(userId: "your_user_id", ui: { builder in
	if AppDelegate.CUSTOM_UI {
		builder.alertButtonText = .orange
		builder.accentColor = .orange
	}
})
// with SSO Key
TchekSdk.configure(keySSO: txtFieldSSO.text ?? "",
				   builder: builder) { tchekSSO in
				// TODO
}

// or TchekSDK Key
TchekSdk.configure(key: "6d52f1de4ffda05cb91c7468e5d99714f5bf3b267b2ae9cca8101d7897d2",
				   builder: builder) {
				// TODO
}
```
# Launch a Shoot Inspect
OR
# Launch Shoot Inspect at End (useful to launch detection)
```
let builder = TchekShootInspectBuilder(delegate: self) { builder in
	builder.thumbBg = .brown
	...
}

let viewController = TchekSdk.shootInspect(builder: builder)
// OR
let viewController = TchekSdk.shootInspectEnd(tchekId: "tchekScandId", builder: builder)

navigationController.pushViewController(viewController, animated: true)
```

* Callback
```
extension ViewController: TchekShootInspectDelegate {
	func onDetectionEnd(tchekScan: TchekScan, immatriculation: String?) {
	}
}
```

# Launch a Fast Track
```
let builder = TchekFastTrackBuilder(tchekId: "any-tchek-id", delegate: self) { builder in
	builder.navBarBg = .purple
	...
}

let viewController = TchekSdk.fastTrack(builder: builder)

navigationController.pushViewController(viewController, animated: true)
```

* Callback
```
extension ViewController: TchekFastTrackDelegate {
	func onReportCreated(tchekScan: TchekScan) {
	}
}
```

# Display a Report
```
let builder = TchekReportBuilder(tchekId: "any-tchek-id", delegate: self) { builder in
	builder.bg = .purple
	...
}

let viewController = TchekSdk.report(builder: builder)

navigationController.pushViewController(viewController, animated: true)
```

* Callback
```
extension ViewController: TchekReportDelegate {
	func onReportUpdate(tchekScan: TchekScan) {
	}
}
```

# Load All Tchek

```
TchekSdk.loadAllTchek(type: .mobile,
					  deviceId: nil,
					  search: nil,
					  limit: 50,
					  page: 0) { error in
	print("error: \(error)")
} onSuccess: { tcheks in
	tcheks.forEach { tchek in
		print("tchek.id: \(tchek.id), tchek.status: \(tchek.status)")
	}
}
```

# Get Report Url

```
TchekSdk.getReportUrl(tchekId: tchekId,
					  validity: 1,
					  cost: false) { error in
	print("error: \(error)")
} onSuccess: { url in
	print("url: \(url)")
}
```
- tchekId: The TchekScan id you want to load
- validity: The url validity in days. Can be null => infinite
- cost: The boolean indicates that the costs are displayed in the report
<br>
<br>

![](https://github.com/sofianetchek/sample_ios_sdk/blob/main/Screenshots/loadAllTchek.png?raw=true "")

# Delete a Tchek
```
TchekSdk.deleteTchek(tchekId: "any-tchek-id") {
	print("Delete Tchek Failed")
} onSuccess: {
	print("Delete Tchek Success")
}
```

# Socket Subscriber

* Subscribe: eg: on configure completion

```
private func socketSubscriber() {
	tchekSocketManager = TchekSdk.socketManager(type: TchekScanType.mobile, device: nil)
	
	newTchekEmitter = NewTchekEmitter { tchek in
		print("\(self)-newTchekEmitter-NewTchek-tchek.id: \(tchek.id), tchek.vehicle?.immat: \(String(describing: tchek.vehicle?.immat)), tchek.detectionFinished: \(tchek.detectionFinished), tchek.detectionInProgress: \(tchek.detectionInProgress)")
	}
	
	detectionFinishedEmitter = DetectionFinishedEmitter { tchek in
		print("\(self)-detectionFinishedEmitter-detectionFinished-tchek.id: \(tchek.id), tchek.vehicle?.immat: \(String(describing: tchek.vehicle?.immat)), tchek.detectionFinished: \(tchek.detectionFinished), tchek.detectionInProgress: \(tchek.detectionInProgress)")
	}

	createReportEmitter = CreateReportEmitter { tchek in
		print("\(self)-createReportEmitter-createReport-tchek.id: \(tchek.id), tchek.vehicle?.immat: \(String(describing: tchek.vehicle?.immat)), tchek.detectionFinished: \(tchek.detectionFinished), tchek.detectionInProgress: \(tchek.detectionInProgress)")
	}

	deleteTchekEmitter = DeleteTchekEmitter { tchekId in
		print("\(self)-deleteTchekEmitter-deleteTchek-tchekId: \(tchekId)")
	}
			
	tchekSocketManager!.subscribe(newTchekEmitter!)
	tchekSocketManager!.subscribe(detectionFinishedEmitter!)
	tchekSocketManager!.subscribe(createReportEmitter!)
	tchekSocketManager!.subscribe(deleteTchekEmitter!)
}
```

* Do not forget to destroy them

```
override func viewDidDisappear(_ animated: Bool) {
	super.viewDidDisappear(animated)
	tchekSocketManager?.destroy()
}
```


> [!WARNING]
>  Note About Multitasking in iOS​ 

As you probably know, iOS is very picky about what you can do in the background. As such, dont expect that your socket connection will survive in the background! Youll probably stop receiving events within seconds of the app going into the background. So its better to create a task that will gracefully close the connection when it enters the background, and then reconnect the socket when the app comes back into the foreground.

# UI Style

1. Shoot Inspect

![](https://github.com/sofianetchek/sample_android_sdk/blob/main/Screenshots/SDK_UI_Style-1-ShootInspect.png?raw=true "")

2. Fast Track

![](https://github.com/sofianetchek/sample_android_sdk/blob/main/Screenshots/SDK_UI_Style-2-FastTrack.png?raw=true "")

3. Report

![](https://github.com/sofianetchek/sample_android_sdk/blob/main/Screenshots/SDK_UI_Style-3-Report.png?raw=true "")