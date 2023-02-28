import           Control.Monad                         ( replicateM_
                                                       , filterM
                                                       , liftM
                                                       , join
                                                       , unless
                                                       )
import           Data.IORef      
import           Data.Char
import           Data.List                                                 
import           Data.Foldable                         ( traverse_ )
import           Data.Monoid
import           Graphics.X11.ExtraTypes.XF86
import           System.Exit
import           System.Directory                      ( doesFileExist )
import           System.IO                             ( hPutStr
                                                       , hClose
                                                       , writeFile
                                                       )
import           XMonad
import           XMonad.Actions.CycleWS                ( Direction1D(..)
                                                       , WSType(..)
                                                       , anyWS
                                                       , findWorkspace
                                                       )
import           XMonad.Actions.DynamicProjects        ( Project(..)
                                                       , dynamicProjects
                                                       , switchProjectPrompt
                                                       )
import           XMonad.Actions.DynamicWorkspaces      ( removeWorkspace )
import           XMonad.Actions.FloatKeys              ( keysAbsResizeWindow
                                                       , keysResizeWindow
                                                       )
import           XMonad.Actions.RotSlaves              ( rotSlavesUp )
import           XMonad.Actions.SpawnOn                ( manageSpawn
                                                       , spawnOn
                                                       )
import           XMonad.Actions.WithAll                ( killAll )
import           XMonad.Actions.CopyWindow             ( killAllOtherCopies
                                                       , copy
                                                       , copyToAll
                                                       , kill1
                                                       )
import           XMonad.Hooks.EwmhDesktops             ( ewmh
                                                       , ewmhFullscreen
                                                       )
import           XMonad.Hooks.FadeInactive             
import           XMonad.Hooks.InsertPosition           ( Focus(..)
                                                       , Position(..)
                                                       --, Position(Above)
                                                       , insertPosition
                                                       )
import           XMonad.Hooks.ManageDocks              ( Direction2D(..)
                                                       , ToggleStruts(..)
                                                       , avoidStruts
                                                       , docks
                                                       )
import           XMonad.Hooks.ManageHelpers            ( (-?>)
                                                       , composeOne
                                                       , doCenterFloat
                                                       , doFullFloat
                                                       , isDialog
                                                       , isFullscreen
                                                       , isInProperty
                                                       )
import           XMonad.Hooks.UrgencyHook              ( UrgencyHook(..)
                                                       , withUrgencyHook
                                                       )
import           XMonad.Layout.Gaps                    ( gaps )
import           XMonad.Layout.MultiToggle             ( Toggle(..)
                                                       , mkToggle
                                                       , single
                                                       )
import           XMonad.Layout.MultiToggle.Instances   ( StdTransformers(NBFULL) )
import           XMonad.Layout.NoBorders               ( smartBorders )
import           XMonad.Layout.PerWorkspace            ( onWorkspace )
import           XMonad.Layout.Spacing                 ( spacing )
import           XMonad.Layout.HintedGrid
import           XMonad.Layout.ThreeColumns            ( ThreeCol(..) )
import           XMonad.Layout.Spiral
import           XMonad.Layout.Fullscreen
import           XMonad.Prompt                         ( XPConfig(..)
                                                       , amberXPConfig
                                                       , XPPosition(CenteredAt)
                                                       )
import           XMonad.Util.EZConfig                  ( mkNamedKeymap
                                                       , additionalKeys
                                                       , removeKeys                                                      
                                                       )
import           XMonad.Util.NamedActions              ( (^++^)
                                                       , NamedAction (..)
                                                       , addDescrKeys'
                                                       , addName
                                                       , showKm
                                                       , subtitle
                                                       )
import           XMonad.Util.NamedScratchpad           ( NamedScratchpad(..)
                                                       , customFloating
                                                       , defaultFloating
                                                       , namedScratchpadAction
                                                       , namedScratchpadManageHook
                                                       )
import           XMonad.Util.Run                       ( safeSpawn
                                                       , spawnPipe
                                                       )
import           XMonad.Util.SpawnOnce                 ( spawnOnce )
import           XMonad.Util.WorkspaceCompare          ( getSortByIndex )
import           XMonad.Util.XSelection                ( safePromptSelection )

import qualified Control.Exception                     as E
import qualified Data.Map                              as M
import qualified XMonad.StackSet                       as W
import qualified XMonad.Util.NamedWindows              as W

-- Imports for Polybar --
import qualified Codec.Binary.UTF8.String              as UTF8
import qualified Data.Set                              as S
import qualified DBus                                  as D
import qualified DBus.Client                           as D
import           XMonad.Hooks.DynamicLog


main :: IO ()
main = mkDbusClient >>= main'

main' :: D.Client -> IO ()
main' dbus = xmonad . docks . ewmh . ewmhFullscreen . dynProjects . keybindings . urgencyHook $ def
  { terminal           = myTerminal
  , focusFollowsMouse  = False
  , clickJustFocuses   = False
  , borderWidth        = 2
  , modMask            = myModMask
  , workspaces         = myWS
  , normalBorderColor  = "#25211B" -- #dark brown (372716)  
  , focusedBorderColor = "#627A92" -- nice blue
  , mouseBindings      = myMouseBindings
  , layoutHook         = myLayout
  , manageHook         = myManageHook
  , logHook            = myPolybarLogHook dbus
  , startupHook        = myStartupHook
  }
 where
  myModMask   = mod4Mask -- super as the mod key
  dynProjects = dynamicProjects projects
  keybindings = addDescrKeys' ((myModMask, xK_F1), showKeybindings) myKeys
  urgencyHook = withUrgencyHook LibNotifyUrgencyHook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
myStartupHook = startupHook def

-- original idea: https://pbrisbin.com/posts/using_notify_osd_for_xmonad_notifications/
data LibNotifyUrgencyHook = LibNotifyUrgencyHook deriving (Read, Show)

instance UrgencyHook LibNotifyUrgencyHook where
  urgencyHook LibNotifyUrgencyHook w = do
    name     <- W.getName w
    maybeIdx <- W.findTag w <$> gets windowset
    traverse_ (\i -> safeSpawn "notify-send" [show name, "workspace " ++ i]) maybeIdx

------------------------------------------------------------------------
-- Polybar settings (needs DBus client).
--
mkDbusClient :: IO D.Client
mkDbusClient = do
  dbus <- D.connectSession
  D.requestName dbus (D.busName_ "org.xmonad.log") opts
  return dbus
 where
  opts = [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]

-- Emit a DBus signal on log updates
dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str =
  let opath  = D.objectPath_ "/org/xmonad/Log"
      iname  = D.interfaceName_ "org.xmonad.Log"
      mname  = D.memberName_ "Update"
      signal = D.signal opath iname mname
      body   = [D.toVariant $ UTF8.decodeString str]
  in  D.emit dbus $ signal { D.signalBody = body }

polybarHook :: D.Client -> PP
polybarHook dbus =
  let wrapper c s | s /= "NSP" = wrap ("%{F" <> c <> "} ") " %{F-}" s
                  | otherwise  = mempty
      blue   = "#619DEC"
      gray   = "#8D868F"
      white  = "#FFFFFF"
      orange = "#CF6A4C"
      yellow = "#F9F4CD"
      green  = "#8F9D6A"
      darkgray    = "#5F5A60"
  in  def { ppOutput          = dbusOutput dbus
          , ppCurrent         = wrapper blue
          , ppVisible         = wrapper white
          , ppUrgent          = wrapper orange
          , ppHidden          = wrapper gray
          , ppHiddenNoWindows = wrapper darkgray
          , ppTitle           = wrapper yellow . shorten 120
          }

myPolybarLogHook dbus = myLogHook <+> dynamicLogWithPP (polybarHook dbus)

myTerminal     = "alacritty"
myBashTerminal = "alacritty --hold -e bash"
myZshTerminal = "alacritty --hold -e zsh"

delayTerminal      = "sleep 2s && alacritty"
myGuildView        = "alacritty --hold -e ./guild-operators/scripts/cnode-helper-scripts/gLiveView.sh"
cnodeStatus  = "alacritty -o font.size=5 -e systemctl status cardano-node"
myCardanoCli       = "sleep 20m && alacritty --hold -e node_check"
appLauncher        = "rofi -modi drun,ssh,window -show drun -show-icons"
playerctl c        = "playerctl --player=spotify,%any " <> c

calcLauncher = "rofi -show calc -modi calc -no-show-match -no-sort"
emojiPicker  = "rofi -modi emoji -show emoji -emoji-mode copy"
--spotlight    = "rofi -modi spotlight -show spotlight -spotlight-mode copy"

-- Hue Lighting Junk
lghtLvl l b   = "hue light " <> l <> " brightness " <> b
lghtOff l     = "hue light " <> l <> " off"
lghtOn  l     = "hue light " <> l <> " on"
blackOut      = "hue light 1 off && hue light 2 off && hue light 5 off && hue light 6 off && hue light 8 off && hue light 9 off && hue light 14 off && hue light 16 off && hue light 17 off && hue light 18 off && hue light 19 off && hue light 20 off && hue light 21 off && hue light 3 off "
screenLocker  = "betterlockscreen -l dim"
darkLights    = "hue light 1 off && hue light 2 off && hue light 5 off && hue light 6 off && hue light 8 off && hue light 9 off && hue light 14 off && hue light 16 off && hue light 17 relax && hue light 17 brightness 28% && hue light 18 off && hue light 19 off && hue light 20 off && hue light 21 off && hue light 3 relax"
chillLights   = "hue light 3 relax && hue light 14 relax && hue light 17 relax && hue light 8 relax && hue light 5 relax && hue light 6 relax && hue light 9 relax"
coldLights    = "hue light 3 concentrate && hue light 14 concentrate && hue light 17 concentrate && hue light 8 concentrate && hue light 5 concentrate && hue light 6 pink && hue light 9 concentrate"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
showKeybindings :: [((KeyMask, KeySym), NamedAction)] -> NamedAction
showKeybindings xs =
  let
    filename = "/home/bismuth/.xmonad/keybindings"
    command f = "alacritty -e dialog --title 'XMonad Key Bindings' --colors --hline \"$(date)\" --textbox " ++ f ++ " 50 100"
  in addName "Show Keybindings" $ do
    b <- liftIO $ doesFileExist filename
    unless b $ liftIO (writeFile filename (unlines $ showKm xs))
    spawnOn webWs $ command filename -- show dialog on webWs
    windows $ W.greedyView webWs     -- switch to webWs


 -- I used "xev" to figure out exactly what key I was pressing to make many of these 
myKeys conf@XConfig {XMonad.modMask = modm} =
  keySet "Applications"
    [ key "Slack"           (modm                , xK_F2            ) $ spawnOn comWs "slack"
    , key "Youtube"         (modm .|. controlMask, xK_y             ) $ spawnOn webWs "brave --app=https://youtube.com/"
    , key "Private Browser" (modm .|. controlMask, xK_p             ) $ spawnOn webWs "brave --incognito"
    ] ^++^
  keySet "Lights"
    [ key "DarkerWarm"      (0, xF86XK_MonBrightnessDown      ) $ spawn darkLights
    , key "BrighterWarm"    (0, xF86XK_MonBrightnessUp        ) $ spawn chillLights
    , key "BrighterBlue"    (modm, xF86XK_MonBrightnessUp     ) $ spawn coldLights
    ] ^++^    
  keySet "Audio"
    [ key "Mute"            (0, xF86XK_AudioMute                   ) $ spawn "amixer -q set Master toggle"
    , key "Lower volume"    (0, xF86XK_AudioLowerVolume            ) $ spawn "amixer -q set Master 3%-"
    , key "Raise volume"    (0, xF86XK_AudioRaiseVolume            ) $ spawn "amixer -q set Master 3%+"
    , key "Lower S volume"  (modm, xF86XK_AudioLowerVolume         ) $ spawn $ playerctl "volume 0.05-"
    , key "Raise S volume"  (modm, xF86XK_AudioRaiseVolume         ) $ spawn $ playerctl "volume 0.05+"
    , key "Mute S volume"   (modm, xF86XK_AudioMute                ) $ spawn $ playerctl "volume 0.0"
    , key "100% S volume"   (modm .|. shiftMask , xF86XK_AudioMute ) $ spawn $ playerctl "volume 1.0"
    , key "Play / Pause"    (0, xF86XK_AudioPlay                   ) $ spawn $ playerctl "play-pause"
    , key "Stop"            (0, xF86XK_AudioStop                   ) $ spawn $ playerctl "stop"
    , key "Previous"        (0, xF86XK_AudioPrev                   ) $ spawn $ playerctl "previous"
    , key "Next"            (0, xF86XK_AudioNext                   ) $ spawn $ playerctl "next"
    ] ^++^
  keySet "Launchers"
    [ key "Terminal"        (modm .|. shiftMask  , xK_Return  ) $ spawn (XMonad.terminal conf)
    , key "Bash Terminal"   (modm .|. controlMask,  xK_b      ) $ spawn myBashTerminal   
    , key "Zsh Terminal"    (modm .|. controlMask,  xK_z      ) $ spawn myZshTerminal    
    , key "Apps (Rofi)"     (0, xF86XK_LaunchA                ) $ spawn appLauncher
    , key "Calc (Rofi)"     (modm .|. shiftMask  , xK_c       ) $ spawn calcLauncher
    , key "Emojis (Rofi)"   (modm .|. shiftMask  , xK_m       ) $ spawn emojiPicker
    -- , key "Spotlight (Rofi)"(modm .|. shiftMask  , xK_0       ) $ spawn spotlight
    , key "Lock screen"     (modm .|. controlMask, xK_l       ) $ spawn screenLocker
    ] ^++^
  keySet "Layouts"
    [ key "Next"            (modm              , xK_space     ) $ sendMessage NextLayout
    , key "Reset"           (modm .|. shiftMask, xK_space     ) $ setLayout (XMonad.layoutHook conf)
    , key "Fullscreen"      (modm              , xK_f         ) $ sendMessage (Toggle NBFULL)
    ] ^++^
  keySet "Polybar"
    [ key "Toggle"          (modm              , xK_equal     ) togglePolybar
    ] ^++^
  keySet "Projects"
    [ key "Switch prompt"   (0, xF86XK_KbdBrightnessDown      ) $ switchProjectPrompt projectsTheme
    ] ^++^
  keySet "Scratchpads"
    [ key "Audacious"       (modm .|. controlMask,  xK_a      ) $ runScratchpadApp audacious
    , key "bottom"          (0, xF86XK_LaunchB                ) $ runScratchpadApp btm
    , key "GuildView"       (modm .|. controlMask,  xK_g      ) $ spawnOn spoWs myGuildView
    , key "Files"           (modm .|. controlMask,  xK_f      ) $ runScratchpadApp nautilus
    , key "Screen recorder" (modm .|. controlMask,  xK_r      ) $ runScratchpadApp scr
    , key "Spotify"         (modm .|. controlMask,  xK_s      ) $ runScratchpadApp spotify
    , key "Mpv"             (modm .|. controlMask,  xK_m      ) $ safePromptSelection "mpv"
    , key "Gimp"            (modm .|. controlMask,  xK_i      ) $ runScratchpadApp gimp
    --, key "Kodi"            (modm .|. controlMask,  xK_k      ) $ runScratchpadApp kodi
    ] ^++^
  keySet "Screens" switchScreen ^++^
  keySet "System"
    [ key "Toggle status bar gap"  (modm              , xK_b  ) toggleStruts
    , key "Logout (quit XMonad)"   (modm .|. shiftMask, xK_q  ) $ io exitSuccess
    , key "Restart XMonad"         (modm              , xK_q  ) $ spawn "xmonad --recompile; xmonad --restart"
    , key "Capture entire screen"  (modm          , xK_Print  ) $ spawn "flameshot full -p ~/Pictures/flameshot/"
    , key "Switch keyboard layout" (modm             , xK_F8  ) $ spawn "kls"
    , key "Disable CapsLock"       (modm             , xK_F9  ) $ spawn "setxkbmap -option ctrl:nocaps"
    ] ^++^
  keySet "Windows"
    [ key "Close focused"   (modm              , xK_BackSpace ) kill1
    , key "Close all in ws" (modm .|. shiftMask, xK_BackSpace ) killAll
    , key "Refresh size"    (modm              , xK_n         ) refresh
    , key "Focus next"      (modm              , xK_j         ) $ windows W.focusDown
    , key "Focus previous"  (modm              , xK_k         ) $ windows W.focusUp
    , key "Focus master"    (modm              , xK_m         ) $ windows W.focusMaster
    , key "Swap master"     (modm              , xK_Return    ) $ windows W.swapMaster
    , key "Swap next"       (modm .|. shiftMask, xK_j         ) $ windows W.swapDown
    , key "Swap previous"   (modm .|. shiftMask, xK_k         ) $ windows W.swapUp
    , key "Shrink master"   (modm              , xK_h         ) $ sendMessage Shrink
    , key "Expand master"   (modm              , xK_l         ) $ sendMessage Expand
    , key "Switch to tile"  (modm              , xK_t         ) $ withFocused (windows . W.sink)
    , key "Rotate slaves"   (modm .|. shiftMask, xK_Tab       ) rotSlavesUp
    , key "Decrease size"   (modm              , xK_d         ) $ withFocused (keysResizeWindow (-10,-10) (1,1))
    , key "Increase size"   (modm              , xK_s         ) $ withFocused (keysResizeWindow (10,10) (1,1))
    , key "Decr  abs size"  (modm .|. shiftMask, xK_d         ) $ withFocused (keysAbsResizeWindow (-10,-10) (1024,752))
    , key "Incr  abs size"  (modm .|. shiftMask, xK_s         ) $ withFocused (keysAbsResizeWindow (10,10) (1024,752))
    , key "Always Visible"  (modm              , xK_v         ) $ windows copyToAll
    , key "Kill Copies"     (modm .|. shiftMask, xK_v         ) $ killAllOtherCopies
    ] ^++^
  keySet "Workspaces"
    [ key "Next"            (modm              , xK_period    ) nextWS'
    , key "Previous"        (modm              , xK_comma     ) prevWS'
    , key "Remove"          (modm              , xF86XK_Eject ) removeWorkspace
    ] ++ switchWsById
 where
  togglePolybar = spawn "polybar-msg cmd toggle &"
  toggleStruts = togglePolybar >> sendMessage ToggleStruts
  keySet s ks = subtitle s : ks
  key n k a = (k, addName n a)
  action m = if m == shiftMask then "Move to " else "Switch to "
-- mod-[1..9]: Switch to workspace N | 
-- mod-shift-[1..9]: Move client to workspace N
  switchWsById =
    [ key (action m <> show i) (m .|. modm, k) (windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask), (copy, shiftMask .|. controlMask)]]
  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  switchScreen =
    [ key (action m <> show sc) (m .|. modm, k) (screenWorkspace sc >>= flip whenJust (windows . f))
        | (k, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m)  <- [(W.view, 0), (W.shift, shiftMask)]]



----------- Cycle through workspaces one by one but filtering out NSP (scratchpads) -----------

nextWS' = switchWS Next
prevWS' = switchWS Prev

switchWS dir =
  findWorkspace filterOutNSP dir anyWS 1 >>= windows . W.view

filterOutNSP =
  let g f xs = filter (\(W.Workspace t _ _) -> t /= "NSP") (f xs)
  in  g <$> getSortByIndex




------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events----------------
myMouseBindings XConfig {XMonad.modMask = modm} = M.fromList

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                      >> windows W.shiftMaster)

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                      >> windows W.shiftMaster)

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout =
  avoidStruts
    . smartBorders
    . fullScreenToggle
    . comLayout
    . vscLayout    
    . musLayout     
    . webLayout
    . mscLayout
    . devLayout   
    . spoLayout
    . vmsLayout
    . secLayout $ (tiled ||| Mirror tiled ||| column3 ||| full)
   where
     -- default tiling algorithm partitions the screen into two panes
     grid                    = gapSpaced 3 $ Grid False
     grid_strict_portrait    = GridRatio grid_portrait False 
     grid_strict_landscape   = GridRatio grid_landscape False 
     tiled                   = gapSpaced 3 $ Tall nmaster delta golden_ratio
     doubletiled             = gapSpaced 0 $ Tall nmasterTwo delta golden_ratio
     tiled_nogap             = gapSpaced 0 $ Tall nmaster delta golden_ratio
     tiled_spaced            = gapSpaced 10 $ Tall nmaster delta ratio
     column3_og              = gapSpaced 10 $ ThreeColMid 1 (3/100) (1/2)
     video_tile              = gapSpaced 2 $ Mirror (Tall 1 (1/50) (3/5))
     full                    = gapSpaced 3 Full
     fuller                  = gapSpaced 0 Full
     column3                 = gapSpaced 3 $ ThreeColMid 1 (33/100) (1/2)
     goldenSpiral            = gapSpaced 3 $ spiral golden_ratio
     silverSpiral            = gapSpaced 3 $ spiralWithDir East CCW ratio

     -- The default number of windows in the master pane
     nmaster = 1
     nmasterTwo = 2

     -- Default proportions of screen occupied by master pane
     ratio          = 1/2
     golden_ratio   = 1/1.618033988749894e0
     grid_portrait     = 3/4
     grid_landscape    = 4/3

     -- Percent of screen to increment by when resizing panes
     delta   = 2/100

     -- Gaps bewteen windows
     myGaps gap  = gaps [(U, gap),(D, gap),(L, gap),(R, gap)]
     gapSpaced g = spacing g . myGaps g

     -- Per workspace layout
     webLayout = onWorkspace webWs (tiled_nogap ||| fuller ||| goldenSpiral ||| tiled_spaced ||| full ||| grid ||| grid_strict_landscape)
     mscLayout = onWorkspace mscWs (doubletiled ||| Mirror grid_strict_landscape ||| grid_strict_landscape ||| Mirror grid_strict_portrait ||| grid_strict_portrait ||| column3_og ||| tiled_spaced ||| grid ||| fuller ||| Mirror tiled_nogap ||| Mirror tiled ||| tiled_nogap ||| tiled ||| video_tile ||| full  ||| column3 ||| goldenSpiral ||| silverSpiral)
     musLayout = onWorkspace musWs (fuller ||| tiled)
     vscLayout = onWorkspace vscWs (Mirror tiled_nogap ||| fuller ||| tiled_nogap ||| goldenSpiral ||| full ||| Mirror tiled ||| column3_og )
     comLayout = onWorkspace comWs (tiled ||| full ||| column3 ||| goldenSpiral)
     spoLayout = onWorkspace spoWs (goldenSpiral ||| column3 ||| Mirror tiled_nogap ||| fuller ||| full ||| tiled)
     devLayout = onWorkspace devWs (goldenSpiral ||| full ||| tiled ||| Mirror tiled ||| column3)
     secLayout = onWorkspace secWs (tiled ||| fuller ||| column3) 
     vmsLayout = onWorkspace vmsWs (full ||| tiled ||| fuller ||| column3) 

     -- Fullscreen
     fullScreenToggle = mkToggle (single NBFULL)


-- Defining Rectangles using absolute points (https://gist.github.com/tkf/1343015)
doFloatAbsRect :: Rational -> Rational -> Rational -> Rational -> ManageHook
doFloatAbsRect x y width height = do
  win <- ask -- get Window
  q <- liftX (floatLocation win) -- get (ScreenId, W.RationalRect)
  let sid = fst q :: ScreenId
      oirgRect = snd q :: W.RationalRect
      ss2ss ss = -- :: StackSet ... -> StackSet ...
        W.float win newRect ss where
          mapping = map (\s -> (W.screen s, W.screenDetail s)) (c:v) where
            c = W.current ss
            v = W.visible ss
          maybeSD = lookup sid mapping
          scRect  = fmap screenRect maybeSD
          newRect = case scRect of
            Nothing -> oirgRect
            Just (Rectangle x0 y0 w0 h0) ->
              W.RationalRect x' y' w' h' where
                W.RationalRect x1 y1 w1 h1 = oirgRect
                x' = if x0 == 0 then x1 else x / (fromIntegral x0)
                y' = if y0 == 0 then y1 else y / (fromIntegral y0)
                w' = if w0 == 0 then w1 else width / (fromIntegral w0)
                h' = if h0 == 0 then h1 else height / (fromIntegral h0)
  doF ss2ss

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- WM_CLASS(STRING) = "brave-browser", "Brave-browser"  
-- WM_CLASS(STRING) = "keepassxc", "KeePassXC"
-- WM_CLASS(STRING) = "discord.com__app", "Brave-browser"
-- WM_CLASS(STRING) = "mstdn.social__home", "Brave-browser"
-- WM_CLASS(STRING) = "tokodon", "tokodon"
-- xprop | grep WM_RESOURCE
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.

type AppName      = String
type AppTitle     = String
type AppClassName = String
type AppCommand   = String

data App
  = ClassApp AppClassName AppCommand
  | TitleApp AppTitle AppCommand
  | NameApp AppName AppCommand
  deriving Show

audacious = ClassApp "Audacious"            "audacious"
btm       = TitleApp "btm"                  "alacritty -t btm -e btm --color gruvbox --default_widget_type proc"
virtbox   = ClassApp "VirtualBox Machine"   "VBoxManage startvm 'plutusVM_bismuth'"
calendar  = ClassApp "Orage"                "orage"
cmatrix   = TitleApp "cmatrix"              "alacritty cmatrix"
eog       = NameApp  "eog"                  "eog"
evince    = ClassApp "Evince"               "evince"
gimp      = ClassApp "Gimp"                 "gimp"
keepass   = ClassApp "KeePassXC"            "keepassxc"
-- mastodon  = TitleApp "Mastodon"          "tokodon"
nautilus  = ClassApp "Org.Gnome.Nautilus"   "nautilus"
office    = ClassApp "libreoffice-draw"     "libreoffice-draw"
pavuctrl  = ClassApp "Pavucontrol"          "pavucontrol"
scr       = ClassApp "SimpleScreenRecorder" "simplescreenrecorder"
spotify   = ClassApp "Spotify"              "spotify"
vlc       = ClassApp "Vlc"                  "vlc --qt-minimal-view"
mpv       = ClassApp "Mpv"                  "mpv" 
kodi      = ClassApp "Kodi"                 "kodi"
vscodium  = ClassApp "VSCodium"             "vscodium"
yad       = ClassApp "Yad"                  "yad --text-info --text 'XMonad'"

myManageHook = manageApps <+> manageSpawn <+> manageScratchpads
 where
  isBrowserDialog     = isDialog <&&> className =? "Brave-browser"
  isFileChooserDialog = isRole =? "GtkFileChooserDialog"
  isPopup             = isRole =? "pop-up"
  isSplash            = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH"
  isRole              = stringProperty "WM_WINDOW_ROLE"
  tileBelow           = insertPosition Below Newer
  tileAbove           = insertPosition Above Newer
  doVideoFloat        = doFloatAbsRect 240 720 600 300
  doCalendarFloat     = customFloating (W.RationalRect (11 / 15) (1 / 48) (1 / 4) (1 / 8))
  manageScratchpads = namedScratchpadManageHook scratchpads
  anyOf :: [Query Bool] -> Query Bool
  anyOf = foldl (<||>) (pure False)
  match :: [App] -> Query Bool
  match = anyOf . fmap isInstance
  manageApps = composeOne
    [ isInstance calendar                      -?> doCalendarFloat
    , match [ virtbox
            ]                                  -?> tileAbove
    , match [ keepass
            , mpv
            ]                                  -?> tileAbove
    , match [ audacious
            , eog
            , nautilus
            , office
            , pavuctrl
            , scr
            ]                                  -?> doCenterFloat
    , match [ btm
            , evince
            , gimp
            ]                                  -?> doFullFloat
    , resource =? "desktop_window"             -?> doIgnore
    , resource =? "kdesktop"                   -?> doIgnore
    , anyOf [ isPopup
            ]                                  -?> tileBelow  
    , anyOf [ isFileChooserDialog
            , isDialog
            , isSplash
            , isBrowserDialog
            ]                                  -?> doCenterFloat        
    , isFullscreen                             -?> doFullFloat
    , pure True                                -?> tileBelow
    ]

isInstance (ClassApp c _) = className =? c
isInstance (TitleApp t _) = title =? t
isInstance (NameApp n _)  = appName =? n

getNameCommand (ClassApp n c) = (n, c)
getNameCommand (TitleApp n c) = (n, c)
getNameCommand (NameApp  n c) = (n, c)

getAppName    = fst . getNameCommand
getAppCommand = snd . getNameCommand

scratchpadApp :: App -> NamedScratchpad
scratchpadApp app = NS (getAppName app) (getAppCommand app) (isInstance app) defaultFloating

runScratchpadApp = namedScratchpadAction scratchpads . getAppName

scratchpads = scratchpadApp <$> [ audacious, btm, nautilus, scr, spotify, gimp, mpv, virtbox ]

------------------------------------------------------------------------
-- Workspaces
--
webWs = "web"
mscWs = "msc"
musWs = "mus"
vscWs = "vsc"
comWs = "com"
spoWs = "spo"
devWs = "dev"
secWs = "sec"
vmsWs = "vms"

myWS :: [WorkspaceId]
myWS = [webWs, mscWs, musWs, vscWs, comWs, spoWs, devWs, secWs, vmsWs]

------------------------------------------------------------------------
-- Dynamic Projects
--
projects :: [Project]
projects =
  [ Project { projectName      = webWs
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawn "brave"
            }
  , Project { projectName      = mscWs
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawn myTerminal
            }
  , Project { projectName      = musWs
            , projectDirectory = "~/music/"
            , projectStartHook = Just $ runScratchpadApp spotify
            }
  , Project { projectName      = vscWs
            , projectDirectory = "~/plutus/nix-config.git/flattened/"
            , projectStartHook = Just $ do spawn "codium -n ."
                                           spawn delayTerminal 
                                           
            }
  , Project { projectName      = comWs
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawn "tokodon"
                                           spawn "element-desktop"
                                           spawn "discord"
                                           spawn "telegram-desktop"
                                           spawn "signal"
                                           spawn "slack"
            }
  , Project { projectName      = spoWs
            , projectDirectory = "/home/bismuth/cardano_local/"
            , projectStartHook = Just $ do spawn myTerminal
            }
  , Project { projectName      = devWs
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawn cnodeStatus
            }
  , Project { projectName      = secWs
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawn "keepassxc"
            }
  , Project { projectName      = vmsWs
            , projectDirectory = "~/"
            , projectStartHook = Just $ runScratchpadApp virtbox
            }
  ]

projectsTheme :: XPConfig
projectsTheme = amberXPConfig
  { bgHLight = "#002b36"
  , font     = "xft:Bitstream Vera Sans Mono:size=8:antialias=true"
  , height   = 60
  , position = CenteredAt 0.5 0.5
  }

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
-- NOTE: the (docks . ewmh . ewmhFullscreen) defined in main already overrides handleEventHook
--
-- myEventHook = docksEventHook <+> ewmhDesktopsEventHook <+> fullscreenEventHook

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--TODO: Add trandparency on a per app basis
--TODO: Add figure out how to make one window persistent using a keystroke
myLogHook = fadeInactiveLogHook 1.0
