local fyberLib = require "plugin.fyberLib"

local total_x               = display.contentWidth
local total_y               = display.contentHeight

local center_x              = display.contentWidth * 0.5
local center_y              = display.contentHeight * 0.5


local button_width          = total_x / 8 * 3
local button_height         = total_y / 8

local spacing_x             = total_x / 20
local spacing_y             = total_y / 20

local column_1_x            = 10
local column_2_x            = column_1_x + button_width + spacing_x

local first_row_y           = 40
local second_row_y          = first_row_y  + button_height + spacing_y
local banner_row_y          = second_row_y + button_height + spacing_y

print("total_x=" .. total_x .. ", total_y=" .. total_y .. ", first_row_y=" .. first_row_y .. ", column_1_x=" .. column_1_x)

local rect_show_video = display.newRect(column_2_x + button_width / 2, second_row_y + button_height / 2, button_width, button_height )

local function enable_show_video_button()
  rect_show_video:setFillColor( 1,0,1,1 )
end

local function disable_show_video_button()
  rect_show_video:setFillColor( 1,0,1,0.5 )
end

-----------------------------------------------------------------------------------------
local function on_InterstitialEvent(event)
  -- load status : load_interstitial_available, load_interstitial_not_available, load_interstitial_request_error
  -- show status : show_interstitial_error , show_interstitial_closed
  -- extras : ReasonUserClickedOnAd, ReasonUserClosedAd
end

-----------------------------------------------------------------------------------------
local function on_VideoEvent(event)
  -- load status : load_video_available , load_video_not_available , load_video_request_error
  -- show status : show_video_finished , show_video_aborted , show_video_error
  if event.status == "load_video_available" then
    enable_show_video_button()
  else
    disable_show_video_button()
  end
end

--listeners---------------------------------------------------------------------------------------
local function load_interstitial_listener(event)
  if event.phase == "began" then
    print("load_interstitial")

    fyberLib.CallMethod("load_interstitial")
  end

  return true
end

-----------------------------------------------------------------------------------------
local function load_video_listener(event)
  if event.phase == "began" then
    print("load_video")

    fyberLib.CallMethod("load_video")
  end

  return true
end

-----------------------------------------------------------------------------------------
local function show_interstitial_listener(event)
  if event.phase == "began" then
    print("show_interstitial")

    fyberLib.CallMethod("show_interstitial")
  end

  return true
end

-----------------------------------------------------------------------------------------
local function show_video_listener(event)
  if event.phase == "began" then
    print("show_video")

    fyberLib.CallMethod("show_video")
  end

  return true
end

---
local function load_banner(event)
  if event.phase == "began" then
    print("load_banner")
    fyberLib.CallMethod("load_banner")
  end

  return true
end

local function destroy_banner(event)
  if event.phase == "began" then
    print("destroy_banner")
    fyberLib.CallMethod("destroy_banner")
  end

  return true
end

-----------------------------------------------------------------------------------------
--register bridge listener
Runtime:addEventListener("InterstitialEvent",   on_InterstitialEvent)
Runtime:addEventListener("VideoEvent",  on_VideoEvent)

--UI---------------------------------------------------------------------------------------
local rect_load_interstitial = display.newRect(column_1_x + button_width / 2, first_row_y + button_height / 2, button_width, button_height)
rect_load_interstitial:setFillColor( 1,0,1 )
local text_interstitial = display.newText( "Load interstitial", rect_load_interstitial.x, rect_load_interstitial.y, native.systemFont, 48 )
rect_load_interstitial:addEventListener( "touch", load_interstitial_listener )

local rect_load_video = display.newRect(column_2_x + button_width / 2, first_row_y + button_height / 2, button_width, button_height)
rect_load_video:setFillColor( 1,0,1 )
local text_interstitial = display.newText( "Load video", rect_load_video.x, rect_load_video.y, native.systemFont, 48 )
rect_load_video:addEventListener( "touch", load_video_listener )

-----------------------------------------------------------------------------------------
local rect_show_interstitial = display.newRect(column_1_x + button_width / 2, second_row_y + button_height / 2, button_width, button_height)
rect_show_interstitial:setFillColor( 1,0,1 )
local text_interstitial = display.newText( "Show interstitial", rect_show_interstitial.x, rect_show_interstitial.y, native.systemFont, 48 )
rect_show_interstitial:addEventListener( "touch", show_interstitial_listener )

rect_show_video:setFillColor( 1,0,1,0.5 )
local text_interstitial = display.newText( "Show video", rect_show_video.x, rect_show_video.y, native.systemFont, 48 )
rect_show_video:addEventListener( "touch", show_video_listener )

local rect_load_banner = display.newRect(column_1_x + button_width / 2, banner_row_y + button_height / 2, button_width, button_height)
rect_load_banner:setFillColor( 1,0,1 )
display.newText("Load Banner", rect_load_banner.x, rect_load_banner.y, native.systemFont, 48)
rect_load_banner:addEventListener("touch", load_banner)

local rect_destroy_banner = display.newRect(column_2_x + button_width / 2, banner_row_y + button_height / 2, button_width, button_height)
rect_destroy_banner:setFillColor( 1,0,1 )
display.newText("Destroy Banner", rect_destroy_banner.x, rect_destroy_banner.y, native.systemFont, 48)
rect_destroy_banner:addEventListener("touch", destroy_banner)


if system.getInfo("platformName") == "Android" then
  print("using android credentials")
  fyberLib.CallMethod("init", "35189", "3c2639d04753b318538b8aadbaae9837")
else
  print("using iOS credentials")
  fyberLib.CallMethod("init", "32346", "a0b037caea447827b03591880b00acfa")
end

local gameNetwork = require( "gameNetwork" )

local function initCallback( event )
    if not event.isError then
        native.showAlert( "Success!", "", { "OK" } )
    else
        native.showAlert( "Failed!", event.errorMessage, { "OK" } )
        print( "Error Code:", event.errorCode )
    end
end

local function onSystemEvent( event )
    if ( event.type == "applicationStart" ) then
        gameNetwork.init( "google", initCallback )
        return true
    end
end
Runtime:addEventListener( "system", onSystemEvent )
