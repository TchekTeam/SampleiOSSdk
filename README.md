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
In your AppDelegate you must call the configure method with your SDK Key
```
let builder = TchekBuilder { builder in
	builder.pageIndicatorDot = .darkGray
	builder.pageIndicatorDotSelected = .blue
	builder.alertButtonText = .orange
	builder.accentColor = .orange
}

TchekSdk.configure(key: "my-tchek-sdk-key", builder: builder)
```
# Launch a Shoot Inspect
```
let builder = TchekShootInspectBuilder(delegate: self) { builder in
	builder.thumbBg = .brown
	builder.thumbBorder = .blue
	builder.thumbBorderBadImage = .orange
	builder.thumbBorderGoodImage = .green
	builder.thumbDot = .cyan
	builder.thumbBorderThickness = 0
	builder.thumbCorner = 0

	builder.btnTuto = .yellow
	builder.btnTutoText = .cyan

	builder.btnRetake = .yellow
	builder.btnRetakeText = .cyan

	builder.previewBg = .orange

	builder.btnEndNext = .yellow
	builder.btnEndNextText = .cyan
}

let viewController = TchekSdk.shootInspect(builder: builder)

// Display the Shoot/Inspect UIViewController
navigationController.pushViewController(viewController, animated: true)
```

# Launch a Fast Track
```
let builder = TchekFastTrackBuilder(tchekId: "any-tchek-id", delegate: self) { builder in
	builder.btnAddExtraDamage = .red
	builder.btnAddExtraDamageText = .orange
	builder.btnCreateReport = .yellow
	builder.btnCreateReportText = .cyan
}

let viewController = TchekSdk.fastTrack(builder: builder)

// Display the FastTrack UIViewController
navigationController.pushViewController(viewController, animated: true)
```

# Display a Report
```
let builder = TchekReportBuilder(tchekId: "any-tchek-id", delegate: self) { builder in
	builder.btnReportPrevColor = .lightGray
	builder.btnReportPrevTextColor = .darkGray
	builder.btnReportNextColor = .black
	builder.btnReportNextTextColor = .white
	builder.reportPagingBg = .orange
	builder.reportPagingText = .lightText
	builder.reportPagingTextSelected = .white
	builder.reportPagingIndicator = .white
}

let viewController = TchekSdk.report(builder: builder)

// Display the report UIViewController
navigationController.pushViewController(viewController, animated: true)
```

# Complete documentation

[Documentation](http://doc.tchek.fr)
