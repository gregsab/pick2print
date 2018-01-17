--
-- Created by IntelliJ IDEA.
-- User: Grześ
-- Date: 13.01.2018
-- Time: 07:22
-- To change this template use File | Settings | File Templates.
--

-- Access the Lightroom SDK namespaces.
local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrBinding = import "LrBinding"
local LrFunctionContext = import "LrFunctionContext"
local LrView = import "LrView"


local LrLogger = import 'LrLogger'

-- Create the logger and enable the print function.
local myLogger = LrLogger( 'pick2print-log' )
myLogger:enable( "logfile" ) -- Pass either a string or a table of actions.

local catalog = LrApplication.activeCatalog()
local catPhotos = catalog:getTargetPhotos()


--------------------------------------------------------------------------------
-- Write trace information to the logger.

local function getRating(photo)
    rating = photo:getFormattedMetadata( 'rating' )
    name = photo:getFormattedMetadata( 'fileName' )
    if (rating == nil) then
          rating = 0
    end

--    myLogger:trace("File ["..name.."] has "..rating.." star(s)")
    return rating
end

local function getRatingStats()
    local rating = {}

    for i = 0,5 do
        rating[i] = 0
    end

    local count = 0

    for _, photo in ipairs( catPhotos ) do
        count = count+1
        rt = getRating(photo)
--        photo:setRawMetadata('colorNameForLabel', 'none')

        rating[rt] = rating[rt]+1
    end

    return rating
end

local function permute(tab, n, count)
    n = n or #tab
    for i = 1, count or n do
        local j = math.random(i, n)
        tab[i], tab[j] = tab[j], tab[i]
    end
    return tab
end

local function markForPrinting(photos, n, collection)
    count = n
    for _, photo in ipairs(photos) do
        name = photo:getFormattedMetadata( 'fileName' )
        myLogger:trace("Marking ["..name.."] for printing")
        photo:setRawMetadata('colorNameForLabel', 'blue')

        count = count-1
        if count <= 0 then return end
    end

end

function getCollection(name)
     myLogger.trace("Getting collection ["..name.."]")

     for i,v in ipairs(catalog:getChildCollections()) do
        if name == v:getName() then
            myLogger.trace("Collection ["..name.."] found.")
            return v
        end
     end
end

function pick(n, withrating, collection)
    myLogger:trace("Picking "..n.." with "..withrating.." stars")

    local wr = {}
    local count = 0
    for _, photo in ipairs( catPhotos ) do
        rt = getRating(photo)
        if rt == withrating then
            count = count+1
            table.insert(wr, photo)
            end
    end
    myLogger:trace(count.." found")

    if count == 0 then return 0 end

    if n >= count then
        myLogger:trace("Adding "..#wr.." photos from table ")
        collection:addPhotos(wr)
    else
        myLogger:trace("Coosing RANDOMLY "..n.." files for printing")
        permute(wr, count, n)

        local wr2 = {}
        count2 = n
        for _, photo in ipairs(wr) do
            table.insert(wr2, photo)
            count2 = count2-1
            if count2 <= 0 then
                collection:addPhotos(wr2)
                return n
            end
        end

    end

    return count
end


function pick2print()

import 'LrTasks'.startAsyncTask( function()
    LrFunctionContext.callWithContext( "Pick2print", function( context )
        local rating = getRatingStats()
        local count = 0
        for i = 0,5 do
            count = count+rating[i]
        end

        local info = rating[0].."\t-\n"..rating[1].."\t*\n"..rating[2].."\t**\n"..rating[3]
        info = info.."\t***\n"..rating[4].."\t****\n"..rating[5].."\t*****"
        info = info.."\nTOTAL: "..count


        local f = LrView.osFactory() -- obtain view factory

        local properties = LrBinding.makePropertyTable( context )
        properties.col_name = "toBePrinted"
        properties.nphotos = 210
--        properties.rating_stats = info

        local contents = f:column { -- define view hierarchy
            spacing = f:control_spacing(),
            f:row {
                spacing = f:label_spacing(),
                f:static_text {
                    title = "Rating statistics:",
                    alignment = "right",
                    width = LrView.share "label_width", -- the shared binding
                },
                f:edit_field {
                    width_in_chars = 12,
                    height_in_lines = 7,
                    enabled = false,
                    value = info,
                    font = '<system/small>',
                },
            },
            f:row {
                spacing = f:label_spacing(),
                bind_to_object = properties,
                f:static_text {
                    title = "Collection Name:",
                    alignment = "right",
                    width = LrView.share "label_width", -- the shared binding
                },
                f:edit_field {
                    width_in_chars = 12,
                    value = LrView.bind( 'col_name' ),
                },
            },
            f:row {
                spacing = f:label_spacing(),
                bind_to_object = properties,
                f:static_text {
                    title = "No. of photos:",
                    alignment = "right",
                    width = LrView.share "label_width", -- the shared binding
                },
                f:edit_field {
                    width_in_chars = 12,
                    value = LrView.bind( 'nphotos' ),
                },
            },
        }
        local result = LrDialogs.presentModalDialog( -- invoke the dialog
            {
                title = "Pick photos to be printed",
                contents = contents,
                actionVerb = "Pick",
            }
        )

        myLogger:trace("Picking "..properties.nphotos.." photos")
        if result == "ok" then
            catalog:withWriteAccessDo('Create collection', function()
                collection = catalog:createCollection(properties.col_name, nil, true)
            end)

            catalog:withWriteAccessDo('Picking files', function()
                if not catalog.hasWriteAccess then
                    myLogger:trace("Write access could not be obtained.")
                else
                    myLogger:trace("Write access obtained.")
                    collection:removeAllPhotos()

                    myLogger:trace("Collection "..collection:getName())

                    if collection == nil then
                        myLogger:trace("Could not find/create collection.")
                    else
                        hm = tonumber(properties.nphotos)
                        for i = 5,1,-1 do
                            hm = hm - pick(hm, i, collection)
                            if hm <= 0 then break end
                        end
                    end
                end
            end)
            LrDialogs.message( 'Just finished!', 'Thank you' , 'info')
        end
    end)
end)



end

myLogger:trace("***********************************************************")
pick2print()