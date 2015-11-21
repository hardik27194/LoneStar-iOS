LoneStar is the core project - Foundation for experiments and such...

This is created as a foundation to build individual Binaries for the Apple Submission.  Each standalone project binary has to have a NEW TARGET and the corresponding images. Since this has to be done ANYWAYS, we use some of the images and meta data baked into "TargetProductSpecific" headers and images to be included in the project.

When the project is built as LoneStar target, it is an experimental binary (and also helpful for the build of Icons, etc - as explained separately).

When an Individual project is built, it is a Foundation of the target Standalone App.  For example 5MCC, FerriCA, etc.  Note that we desire to build InApp purchase scheme for subsequent editions - so we will do the App with the Core Product name (without reference to edition like 7, or year like 2016).  So the 5MCC binary will work for 2015, 2016 editions, etc.  We will always make the imagery and icon update if necessary and build a logic to tell the user that new data is available and they should purchase it.  This will enable us to upsell and show the old data as "stale" through some visual ideas.

This project will have more than 1 target - each target will build the binary to be submitted to Apple when the product is ready for release or update.

Steps to Clone a new TARGET.

    1. On the project organizer hierarchy - Open the project and clone 5MCC (it will create a target called 5MCC copy, and also the Scheme called 5MCC Copy)
    2. Change both names to the ROOT name of the new title (such as FerriCA, RNDrug, etc)
    3. Make sure to go to the folder "ProductSpecificFiles/Headers" and copy 5MCC.pch file to the new file <ROOT>.pch (eg FerriCA.pch, RNDrug.pch) and drag this file into the project under the Group "TargetProductSpecificHeaders"
    4. Copy suitably named graphics file in the folder "ProductSpecificFiles/Images" see existing files for example.  It should be completely cropped version of the Book Cover in highest resolution you can find. JPG is ok, tiff and PNG are also possible.  Do not leave any transparent areas around the edges or anywhere.  Drag this file into the project under "TargetProductSpecificImages"
    5. Find the folder "Assets.xcasset" in the project directory and copy the folder "AppIcon-5MCC.appiconset" to the new folder called "AppIcon-<ROOT>.appiconset" where <ROOT> is the name of the target you chose in Step 2.  (eg AppIcon-FerriCA.xcasset, AppIcon-RnDrug.xcasset, etc).  You don't have to drag this in the project, it will be automatically available
    6. Now go back to the Project Item (as in step 1).  Make sure you are on the General Tab.  Locate the AppIcon asset and change the "AppIcon-5MCC" to your new AppIcon that you cloned (note the images are still old and correspond to 5MCC).
    7. Assuming that you have received the Icon set from the Marketing team, you can update the icons for all resolutions correctly for this AppIcon catalog (say AppIcon-FerriCA.xcasset or AppIcon-RnDrug.xcasset)
    8. Change the Bundle Identifier to the correct new ID - so it will change from com.medpresso.LoneStar-5MCC to the correct new name such as "com.medpresso.LoneStar-FerriCA"
    9. Tap on the Build Phase and type "pch" in the search/filter box.  You will see an entry for "Prefix Header" set to "ProductSpecificFiles/Headers/5MCC.pch" change to "ProductSpecificFiles/Headers/<ROOT>.pch" where <ROOT> is exactly as in the previous steps - in our example it could be "ProductSpecificFiles/Headers/FerriCA.pch"
    10. Edit the PCH (Precompiled Header) file in step 3 to hold the correct values for the Defines in there.  The changes should be obvious, for our
example, we changed as follows:
        #ifndef FerriCA_h
        #define FerriCA_h

        #define SPECIFIC_PRODUCT

        #import "LoneStar-Prefix.pch"

        // If the product specific name starts with a number, replace the number with an underscore (as below for 5MCC)
        #import "FerriCA-Swift.h"

        #define PRODUCT_KEY_NAME    @"FerriCA"    // If it is not Edition Based, then this will be same as the PRODUCT_KEY

        #define ShortName           @"FerriCA16"
        #define LongName            @"Ferri Clinical Advisor (2016)"
        #define IconName            @"FerriCA16.tif"
        #define Editor              @"Fred Ferri, MD"
        #define PublisherColor      COLORFROMHEX(0xff990000)

        #define Image


        #endif /* FerriCA_h */


Now, we are ready to build.  Change the Target build by using the scheme and build.





You can check the walk through call on https://www.youtube.com/watch?v=5pk9ZLGg0iA


Sandeep
20151119