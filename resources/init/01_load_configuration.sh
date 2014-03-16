#!/bin/bash

# Check that configuration has been supplied one way or another
if [ ! -f /etc/env/config.yml ]; then
  echo "The optional environment configuration file, /etc/env/config.yml was not found, using environment variables supplied to Docker. Make sure all required values are supplied."
  
  if [ -z "$GITLAB_HOST" ]; then
    echo -e "\e[1;31mFatal error: It looks like you might not have set any environment properties (GITLAB_HOST is not set). Refer to the Readme file for information on how to configure gitlab-docker.\e[0m"
    exit 1
  fi

  exit 0
fi

# Parse a YAML file into an x=y format easily used in Bash
# http://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script#answer-21189044
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=%s\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# Write each environment property into a file in the manner expected by baseimage's init
result=$(parse_yaml /etc/env/config.yml)
while read -r line; do 
  printf $line | cut -d = -f 2 | tr -d '\n' > /etc/container_environment/$(printf $line | cut -d = -f 1 | tr '[:lower:]' '[:upper:]'); 
done <<< "$result"

