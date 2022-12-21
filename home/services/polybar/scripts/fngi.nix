{ pkgs, ...}:

let
  curl  = "${pkgs.curl}/bin/curl";
  jq  = "${pkgs.jq}/bin/jq";
  sed = "${pkgs.gnused}/bin/sed";
in

  pkgs.writeShellScriptBin "fngi" ''
    echo $(${curl} -s "https://api.alternative.me/fng/" | ${jq} '.data[0]' | ${jq} '.value' | ${sed} 's/"//g')
  ''
/*
chatGPT generated: 
#!/bin/bash

# Asynchronously retrieve the json file from the specified URL
curl "https://api.alternative.me/fng/" -o json_file.json &

# Wait for the curl command to finish
wait

# Extract the value of the "data.value" key from the json file
data_value=$(jq '.data.value' json_file.json)

# Output the value
echo "$data_value"

or echo $(curl "https://api.alternative.me/fng/" | jq '.data[0]' | jq '.value' | sed 's/"//g')
*/