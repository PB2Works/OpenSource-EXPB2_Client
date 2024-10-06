# PB2Works Expanded PB2 Client
This is the client, the actual game that normies play with.

If you want to edit, you first need Adobe Animate. Once you have adobe animate, you double click on `pb2_re34_alt_p.xfl`. And adobe animate will open.

Once you have opened it, settings should be already set in place for you. So just enjoy.

As for actual structure, here it is:

`libs` folder includes AIR libraries, you need it because Expanded PB2 is an AIR app.

`LIBRARY`, `publishtemplates`, `META-INF`, `DOMDocument.xml`, `PublishSettings.xml`, `bin` are all Animate information files, binaries.

`src` is actual code, `pb2_re34_alt_p.app` is published app.

If you have ever dealt with JPEXS, you know what most of files of `src` are all about. However, you don't deal with this, rather you just now deal with `com` inside `src`. More specifically, `pb2` inside `com` which is inside `src`. That's where actual game codes are in.

They also might be in action frames too, so check them if you cannot find code you are looking for inside `src/com/pb2`. To JPEXS users, `PB2Game.as` is the file you are looking for, this once was a `MainTimeline.as`, but we renamed it and we have refactored some objeacts like triggers, regions, doors, images, etc.. into separate files (`PB2Trigger.as`, `PB2Region.as`, `PB2Door.as`, `PB2CustomImage.as` respectively)

Also our Stage3D renderer is in `src/com/pb2/renderer/AcceleratedRenderer.as` if you want that.
To build, you go publish the application using top bar in animate.

Have fun.