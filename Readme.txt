LoneStar is the core project - Foundation for experiments and such...

This is created as a foundation to build individual Binaries for the Apple Submission.  Each standalone project binary has to have a NEW TARGET and the corresponding images. Since this has to be done ANYWAYS, we use some of the images and meta data baked into "TargetProductSpecific" headers and images to be included in the project.

When the project is built as LoneStar target, it is an experimental binary (and also helpful for the build of Icons, etc - as explained separately).

When an Individual project is built, it is a Foundation of the target Standalone App.  For example 5MCC, FerriCA, etc.  Note that we desire to build InApp purchase scheme for subsequent editions - so we will do the App with the Core Product name (without reference to edition like 7, or year like 2016).  So the 5MCC binary will work for 2015, 2016 editions, etc.  We will always make the imagery and icon update if necessary and build a logic to tell the user that new data is available and they should purchase it.  This will enable us to upsell and show the old data as "stale" through some visual ideas.
This project will have more than 1 target - each target will build the binary to be submitted to Apple when the product is ready for release or update.

Steps to Clone a new TARGET.

    1. On the project organizer hierarchy - Open the project .



Sandeep
20151119