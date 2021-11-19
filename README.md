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
	builder.alertButtonText = .orange
	builder.accentColor = .orange
}

TchekSdk.configure(key: "my-tchek-sdk-key", builder: builder)
```
# Launch a Shoot Inspect
OR
# Launch Shoot Inspect at End (useful to launch detection)
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
	builder.tutoPageIndicatorDot = .darkGray
	builder.tutoPageIndicatorDotSelected = .blue
 
	builder.carOverlayGuide = .systemPink

	builder.btnRetake = .yellow
	builder.btnRetakeText = .cyan

	builder.previewBg = .orange

	builder.btnEndNext = .yellow
	builder.btnEndNextText = .cyan

	builder.endBg = .black
	builder.endNavBarBg = .purple
	builder.endNavBarText = .red
}

let viewController = TchekSdk.shootInspect(builder: builder)
// OR
let viewController = TchekSdk.shootInspectEnd(tchekId: tchekId, builder: builder)

// Display the Shoot/Inspect UIViewController
navigationController.pushViewController(viewController, animated: true)
```

# Launch a Fast Track
```
let builder = TchekFastTrackBuilder(tchekId: "any-tchek-id", delegate: self) { builder in
	builder.navBarBg = .purple
	builder.navBarText = .red
	builder.fastTrackBg = .lightGray
	builder.fastTrackText = .purple
	builder.fastTrackPhotoAngle = .red
	builder.fastTrackPhotoAngleText = .orange
	builder.cardBg = .purple

	builder.damagesListBg = .purple
	builder.damagesListText = .red
	builder.damageCellText = .white
	builder.damageCellBorder = .white

	builder.vehiclePatternStroke = .white
	builder.vehiclePatternDamageFill = .orange
	builder.vehiclePatternDamageStoke = .red

	builder.btnAddExtraDamage = .red
	builder.btnAddExtraDamageText = .orange
	builder.btnCreateReport = .yellow
	builder.btnCreateReportText = .cyan

	builder.btnValidateExtraDamage = .yellow
	builder.btnValidateExtraDamageText = .cyan
	builder.btnDeleteExtraDamage = .red
	builder.btnDeleteExtraDamageText = .white
}

let viewController = TchekSdk.fastTrack(builder: builder)

// Display the FastTrack UIViewController
navigationController.pushViewController(viewController, animated: true)
```

# Display a Report
```
let builder = TchekReportBuilder(tchekId: "any-tchek-id", delegate: self) { builder in
	builder.bg = .purple
	builder.navBarBg = .purple
	builder.navBarText = .white
	builder.reportText = .lightGray

	builder.btnPrev = .lightGray
	builder.btnPrevText = .darkGray
	builder.btnNext = .black
	builder.btnNextText = .white

	builder.pagingBg = .purple
	builder.pagingText = .lightText
	builder.pagingTextSelected = .white
	builder.pagingIndicator = .white

	builder.textFieldPlaceHolderText = .white
	builder.textFieldBorder = .white
	builder.textFieldText = .white

	builder.btnValidateSignature = .yellow
	builder.btnValidateSignatureText = .cyan

	builder.damageCellText = .white
	builder.damageCellBorder = .red
	builder.vehiclePatternStroke = .white
	builder.vehiclePatternDamageFill = .orange

	builder.repairCostCellCostBg = .yellow
	builder.repairCostCellCostText = .cyan
	builder.repairCostCellText = .red
	builder.repairCostCellCircleDamageCountBg = .cyan
	builder.repairCostCellCircleDamageCountText = .white

	builder.vehiclePatternStroke = .blue
	builder.vehiclePatternDamageFill = .orange
	builder.vehiclePatternDamageStoke = .red

	builder.extraDamageBg = .purple
	builder.btnValidateExtraDamage = .yellow
	builder.btnValidateExtraDamageText = .cyan
	builder.btnDeleteExtraDamage = .red
	builder.btnDeleteExtraDamageText = .white
}

let viewController = TchekSdk.report(builder: builder)

// Display the report UIViewController
navigationController.pushViewController(viewController, animated: true)
```

# Delete a Tchek
```
TchekSdk.deleteTchek(tchekId: tchekId) {
	print("Delete Tchek Failed")
} onSuccess: {
	print("Delete Tchek Success")
}
```

# Complete documentation

[Documentation](http://doc.tchek.fr)
