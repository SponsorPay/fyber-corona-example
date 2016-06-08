local library = require "plugin.library"

timer.performWithDelay( 1000, function()
  library.loadFyberInterstitial("init", "APP_ID", "SECURITY_TOKEN")
end )

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
end

--listeners---------------------------------------------------------------------------------------
local function load_interstitial_listener(event)
  if event.phase == "began" then
    print("load_interstitial")

    library.loadFyberInterstitial("load_interstitial")
  end

  return true
end

-----------------------------------------------------------------------------------------
local function load_video_listener(event)
  if event.phase == "began" then
    print("load_video")

    library.loadFyberInterstitial("load_video")
  end

  return true
end

-----------------------------------------------------------------------------------------
local function show_interstitial_listener(event)
  if event.phase == "began" then
    print("show_interstitial")

    library.loadFyberInterstitial("show_interstitial")
  end

  return true
end

-----------------------------------------------------------------------------------------
local function show_video_listener(event)
  if event.phase == "began" then
    print("show_video")

    library.loadFyberInterstitial("show_video")
  end

  return true
end

-----------------------------------------------------------------------------------------
--register bridge listener
Runtime:addEventListener("InterstitialEvent",   on_InterstitialEvent)
Runtime:addEventListener("VideoEvent",  on_VideoEvent)

local center_x              = display.contentWidth * 0.5
local center_y              = display.contentHeight * 0.5

--UI---------------------------------------------------------------------------------------
local rect_load_interstitial = display.newRect( center_x - 70, center_y - 80, 125, 100 )
rect_load_interstitial:setFillColor( 1,0,1 )
local text_interstitial = display.newText( "Load interstitial", rect_load_interstitial.x, rect_load_interstitial.y, native.systemFont, 16 )
rect_load_interstitial:addEventListener( "touch", load_interstitial_listener )

local rect_load_video = display.newRect( center_x + 70, center_y - 80, 125, 100 )
rect_load_video:setFillColor( 1,0,1 )
local text_interstitial = display.newText( "Load video", rect_load_video.x, rect_load_video.y, native.systemFont, 16 )
rect_load_video:addEventListener( "touch", load_video_listener )

-----------------------------------------------------------------------------------------
local rect_show_interstitial = display.newRect( center_x - 70, center_y + 80, 125, 100 )
rect_show_interstitial:setFillColor( 1,0,1 )
local text_interstitial = display.newText( "Show interstitial", rect_show_interstitial.x, rect_show_interstitial.y, native.systemFont, 16 )
rect_show_interstitial:addEventListener( "touch", show_interstitial_listener )

local rect_show_video = display.newRect( center_x + 70, center_y + 80, 125, 100 )
rect_show_video:setFillColor( 1,0,1 )
local text_interstitial = display.newText( "Show video", rect_show_video.x, rect_show_video.y, native.systemFont, 16 )
rect_show_video:addEventListener( "touch", show_video_listener )
