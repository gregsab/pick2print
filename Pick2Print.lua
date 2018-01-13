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
        photo:setRawMetadata('colorNameForLabel', 'none')


        rating[rt] = rating[rt]+1
    end

    local info = rating[0].."\n"..rating[1].." *\n"..rating[2].." **\n"..rating[3]
    info = info.." ***\n"..rating[4].." ****\n"..rating[5].." *****"
    info = info.."\nTOTAL: "..count

    myLogger:trace("| "..info:gsub("\n"," | "))

    LrDialogs.message( 'Statistics: ', info , 'info');

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

local function markForPrinting(photos, n)
    count = n
    for _, photo in ipairs(photos) do
        name = photo:getFormattedMetadata( 'fileName' )
        myLogger:trace("Marking ["..name.."] for printing")
        photo:setRawMetadata('colorNameForLabel', 'blue')

        count = count-1
        if count <= 0 then return end
    end

end

local function pick(n, withrating)
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

    catalog:withWriteAccessDo('Picking files for printing', function()
        if n >= count then
            myLogger:trace("Marking all "..count.." files for printing")
            markForPrinting(wr, count)
        else
            myLogger:trace("Marking RANDOMLY "..n.." files for printing")
            permute(wr, count, n)
            markForPrinting(wr, n)
        end
    end)
    return count
end

local function pick2Print(howmany)
    myLogger:trace("***********************************************************")

    import 'LrTasks'.startAsyncTask( function()
        local rating = catalog:withWriteAccessDo('Calculating rating stats', getRatingStats)
        local hm = howmany

        for i = 5,1,-1 do
            hm = hm - pick(hm, i)
            if hm <= 0 then break end
        end

        LrDialogs.message( 'Just finished!', 'Thank you' , 'info')

    end)


end

pick2Print(210)