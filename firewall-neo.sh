#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Run as root, use sudo."
    exit 1
fi

dir="$(cd "$(dirname "$0")" && pwd)"

RED=$'\e[31m'
CYAN=$'\e[36m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
BOLD=$'\e[1m'
RESET=$'\e[0m'


ask() {
    read -p "${BOLD}$1${RESET} " "$2"
}

while true; do
    echo
    echo "${CYAN}${BOLD}1) Add rule:"
    echo "${CYAN}${BOLD}2) Delete rule:"
    echo "${CYAN}${BOLD}3) List rules and settings:"
    echo "${RED}${BOLD}4) Exit.${RESET}"
    ask "${YELLOW}${BOLD}Pick an option: ${RESET}" choice

    case "$choice" in
        1) "$dir/firewall-neo-create.sh" ;;
        2) "$dir/firewall-neo-delete.sh" ;;
        3)
            firewall-cmd --state
            firewall-cmd --list-all
            firewall-cmd --direct --get-all-rules
            ;;
        4) echo "${GREEN}${BOLD}Bye${RESET}"; exit 0 ;;
        *) echo "${RED}${BOLD}Invalid choice.${RESET}" ;;
    esac
done
