{ config, pkgs, ... }:

let
  personas = import ./personas.nix;
  api_key                  = builtins.readFile /home/bismuth/plutus/Documents/Credentials/davinci_api_key.txt;
  curl                     = "${pkgs.curl}/bin/curl";
  jq                       = "${pkgs.jq}/bin/jq";
  sed                      = "${pkgs.gnused}/bin/sed";
in

pkgs.writeShellScriptBin "aipf" ''
    echo " 1.) bob_the_boomer"
    echo " 2.) alfred_the_butler"
    echo " 3.) sully_the_townie"
    echo " 4.) chad_the_romantic"
    echo " 5.) blake_the_academic" 
    echo " 6.) hunter_the_zoomer"
    echo " 7.) jennifer_the_valley_girl" 
    echo " 8.) christine_bling"
    echo " 9.) blackbeard_the_pirate" 
    echo "10.) grigoriy" 
    echo "11.) herzog"
    echo "12.) chomsky" 
    echo "13.) zizek"
    echo "14.) peterson"
    echo " *.) name a famous person"
    read -p "Select a Personality: " chosen
    case $chosen in
      "1")
        persona="${personas.bob_the_boomer}";;
      "2")
        persona="${personas.alfred_the_butler}";;
      "3")
        persona="${personas.sully_the_townie}";;
      "4")
        persona="${personas.chad_the_romantic}";;
      "5")
        persona="${personas.blake_the_academic}";;
      "6")
        persona="${personas.hunter_the_zoomer}";;
      "7")
        persona="${personas.jennifer_the_valley_girl}";;
      "8")
        persona="${personas.christine_bling}";;
      "9")
        persona="${personas.blackbeard_the_pirate}";;
      "10")
        persona="${personas.grigoriy}";;
      "11")
        persona="${personas.herzog}";;
      "12")
        persona="${personas.chomsky}";;
      "13")
        persona="${personas.zizek}";;
      "14")
        persona="${personas.peterson}";;
      *)
        persona="$chosen";;
    esac
    prompt=$1
    full_prompt="The text printed must be indistinguishable from the writing of $persona. From the perspective of the assigned persona, rewrite the following passage: (passage)$prompt(/passage) Ensure your writing is an accurate imitation of the persona by using their language, style, and eccentricities. Utilize references and quotes from the training data to mimic the character's distinctive mannerisms. Use the appropriate perspective (i.e. first or third person) from the given phrase. Incorporate narratives and stories for realism and follow grammar and articulate clearly if the persona requires it. Include misspellings, emoji's, or slang where appropriate and omit quotes and leading carriage returns. Make your impression undetectable from the behavior and style of the person."
    ${curl} https://api.openai.com/v1/completions -s \
    -H 'Content-Type: application/json' \
    -H 'Authorization: Bearer ${api_key}' \
    -d '{
    "model": "text-davinci-003",
    "prompt": "'"$full_prompt"'",
    "max_tokens": 3000,
    "temperature": 0
    }' | ${jq} '.choices' | ${jq} -r '.[0].text' | ${sed} 's/"//g'
  ''