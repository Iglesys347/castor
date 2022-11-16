#!/bin/bash

# Using tput to write bold text and colors
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)

usage() {
    echo "Usage: $(basename "$0") [OPTIONS] COMMAND"
}

help() {
    usage
	echo "
${bold}COMMANDS${normal}
    ${bold}start${normal}
        starts castor
    ${bold}stop${normal}
        stop castor

${bold}OPTIONS${normal}
    ${bold}-h --help${normal}
        Display usage statement
    ${bold}-p --port${normal}=8080
        Port to run the proxy (default=8080)
    ${bold}-m --mode${normal}=socks|http
        Proxy mode, either SOCKS5 or HTTP CONNECT proxy (default=socks) 
"
}

# Read and export values from .env file
if test -f .env; then
	export $(grep -v '^#' .env | xargs)
    # Set default values with env vars (if any)
    port=$PROXY_PORT
    mode=$PROXY_MODE
fi

while getopts ':p:m:h:' OPTION; do
  case "$OPTION" in
    p) port=$OPTARG ;;
    m) mode=$OPTARG ;;
    h) help ;;
    ?)
      help
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

# Check port value
MIN_PORT=1
MAX_PORT=65535
if [ $((port)) -lt "$MIN_PORT" ] || [ $((port)) -gt "$MAX_PORT" ]; then
    echo ${red}"Invalid port number, port should be an interger between $MIN_PORT and $MAX_PORT"${normal}
    exit 1
fi

# Check mode value
if [ $mode != "socks" ] && [ $mode != "http" ]; then
    echo ${red}"Invalid proxy mode, accpeted modes are 'socks' and 'http'"${normal}
    exit 1
fi


# Check command argument
cmd=$1
if [ "$cmd" != "start" ] && [ "$cmd" != "stop" ]; then
    usage
    echo ${red}"Wrong usage, use -h flag to display help"${normal}
    exit 1
fi

# Starting castor proxy
if [ $cmd = "start" ]; then
    echo -ne " Starting $mode proxy on port $port... \r"
    docker-compose up -d -V > /dev/null 2>&1
    echo ${green}"Your castor $mode proxy is available at localhost:$port"${normal}
fi

# Stopping castor proxy
if [ $cmd = "stop" ]; then
    echo -ne " Stoping running castor proxy... \r"
    docker-compose stop  > /dev/null 2>&1
    docker-compose down  > /dev/null 2>&1
    echo ${green}"Successfully stoped castor proxy"${normal}
fi
