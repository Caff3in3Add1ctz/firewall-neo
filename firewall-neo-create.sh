#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Run as root, use sudo"
    exit 1
fi

RED=$'\e[31m'
GREEN=$'\e[32m'
BOLD=$'\e[1m'
RESET=$'\e[0m'

ask() {
    read -rp "${BOLD}$1${RESET} " "$2"
}

valid_ip() {
    local addr="${1%/*}" mask=""
    [[ "$1" == */* ]] && mask="${1#*/}"
    [[ "$addr" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]] || return 1
    for octet in "${BASH_REMATCH[@]:1}"; do
        [ "$octet" -le 255 ] || return 1
    done
    if [ -n "$mask" ]; then
        [[ "$mask" =~ ^[0-9]+$ ]] && [ "$mask" -le 32 ] || return 1
    fi
    return 0
}

ask "Action (allow/block): " action
ask "Direction (in/out): " dir
ask "Protocol (tcp/udp): " proto
ask "Port number: " port
ask "Source or destination IP (blank for any): " ip

case "$action" in
    allow) target="ACCEPT"; rich="accept" ;;
    block) target="DROP";   rich="drop" ;;
    *) echo "${RED}${BOLD}Invalid action.${RESET}"; exit 1 ;;
esac

case "$proto" in
    tcp|udp) ;;
    *) echo "${RED}${BOLD}Invalid protocol.${RESET}"; exit 1 ;;
esac

if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -gt 65535 ]; then
    echo "${RED}${BOLD}Invalid port.${RESET}"
    exit 1
fi

if [ -n "$ip" ] && ! valid_ip "$ip"; then
    echo "${RED}${BOLD}Invalid IP Address.${RESET}"
    exit 1
fi

case "$dir" in
    in)
        if [ -n "$ip" ]; then
            rule="rule family=\"ipv4\" source address=\"$ip\" port port=\"$port\" protocol=\"$proto\" $rich"
        else
            rule="rule family=\"ipv4\" port port=\"$port\" protocol=\"$proto\" $rich"
        fi
        echo "${RED}${BOLD}Rich rule: $rule${RESET}"
        ask "${BOLD}Apply this rule? (y/n): ${RESET}" confirm
        if [ "$confirm" = "y" ]; then
            firewall-cmd --permanent --add-rich-rule="$rule" && firewall-cmd --reload && echo "${GREEN}${BOLD}Rule added.${RESET}"
        else
            echo "${RED}${BOLD}Cancelled${RESET}"
        fi
        ;;
    out)
        args="ipv4 filter OUTPUT 0 -p $proto --dport $port"
        [ -n "$ip" ] && args="$args -d $ip"
        args="$args -j $target"
        echo "${RED}${BOLD}Direct rule: $args${RESET}"
        ask "${BOLD}Apply this rule? (y/n): ${RESET}" confirm
        if [ "$confirm" = "y" ]; then
            firewall-cmd --permanent --direct --add-rule $args && firewall-cmd --reload && echo "${GREEN}Rule added${RESET}"
        else
            echo "${RED}${BOLD}Cancelled.${RESET}"
        fi
        ;;
    *) echo "${RED}${BOLD}Invalid direction.${RESET}"; exit 1 ;;
esac
