{ config, pkgs, ... }:

let
  colors = import ../../themes/colors.nix;
in
{
  services.betterlockscreen = {
    enable = true;
    arguments = {
/*    span_image = false;
      lock_timeout = "240";
      fx_list = "(dim blur dimblur pixel color)";
      dim_level = "1";
      blur_level = "0";
      pixel_scale = "10,1000";
      solid_color = "333333";
      loginbox = "00000066";
      loginshadow = "00000000";
      locktext = ""
      font = "sans-serif";
      ringcolor = "FFE6CE";
      insidecolor = "00000000";
      separatorcolor = "00000000";
      layoutcolor = "00000000";
      ringvercolor = "FFE6CE";
      insidevercolor = "00000000";
      ringwrongcolor = "FFE6CE";
      insidewrongcolor = "FF6C5F";
      keyhlcolor = "FF6C5F";
      bshlcolor = "FF6C5F";
      verifcolor = "FFE6CE";
      timecolor = "FFE6CE"; */
      time_format = "%m/%d/%y %l:%M %p"; 
      locktext = "fucking testing, betch";
      # time-format "%l:%H %p";
    };
  };
}

/* display_on=0
span_image=false
lock_timeout=240
fx_list=(dim blur dimblur pixel color)
dim_level=1
blur_level=1
pixel_scale=10,1000
solid_color=333333
loginbox=00000066
loginshadow=00000000
locktext=""
font="sans-serif"
ringcolor=FFE6CE
insidecolor=00000000
separatorcolor=00000000
layoutcolor=00000000
ringvercolor=FFE6CE
insidevercolor=00000000
ringwrongcolor=FFE6CE
insidewrongcolor=FF6C5F
keyhlcolor=FF6C5F
bshlcolor=FF6C5F
verifcolor=FFE6CE
timecolor=FFE6CE
time_format="%m/%d/%y %l:%H %p" */