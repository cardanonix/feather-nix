{ config, pkgs, ... }:
let
  prompt   = "Write a beat poem about the complex relationship between knowing something and believing something in the style of William S. Burroughs.";
  api_key  = builtins.readFile /home/bismuth/plutus/Documents/Credentials/davinci_api_key.txt;
  curl     = "${pkgs.curl}/bin/curl";
  jq       = "${pkgs.jq}/bin/jq";
  sed      = "${pkgs.gnused}/bin/sed";
  ponysay  = "${pkgs.ponysay}/bin/ponysay";
in
pkgs.writeShellScriptBin "ai_completion" ''
    ${curl} https://api.openai.com/v1/completions \
    -H 'Content-Type: application/json' \
    -H 'Authorization: Bearer ${api_key}' \
    -d '{
    "model": "text-davinci-003",
    "prompt": "${prompt}",
    "max_tokens": 1000,
    "temperature": 0
    }' | ${jq} '.choices' | ${jq} -r '.[0].text' | ${sed} 's/"//g' | ${ponysay}
  ''