#!/bin/bash
# original source from http://www.thecave.com/2014/09/16/using-xcodebuild-to-export-a-ipa-from-an-archive/

xcodebuild clean -project ExperienceTestSingle -configuration Release -alltargets
xcodebuild archive -project ExperienceTestSingle.xcodeproj -scheme ExperienceTestSingle -archivePath ExperienceTestSingle.xcarchive
xcodebuild -exportArchive -archivePath ExperienceTestSingle.xcarchive -exportPath ExperienceTestSingle -exportFormat ipa -exportProvisioningProfile "Delta"
