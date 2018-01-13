--[[----------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

--------------------------------------------------------------------------------

Info.lua
Summary information for Pick2print plug-in.

Adds menu items to Lightroom.

------------------------------------------------------------------------------]]

return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 1.3, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = 'pl.ekskursja.pick2print',



	LrPluginName = "Pick2Print",

	-- Add the menu item to the File menu.

	LrExportMenuItems = {
	    {
		    title = "Pick2Print",
		    file = "Pick2Print.lua",
		}
	},
	VERSION = { major=0, minor=1, revision=1, build=1 },

}
