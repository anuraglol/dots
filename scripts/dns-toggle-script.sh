#!/bin/bash

# DNS Toggle Script
# This script toggles between Cloudflare DNS and default system DNS
# Works with KDE Plasma on Linux Mint

LOG_FILE="/tmp/dns_toggle.log"

# Clear log file content
> $LOG_FILE

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to get the active network interface
get_active_interface() {
    # Try to find active wireless interface first
    WIRELESS_IF=$(ip -o -4 route show default | grep -i wl | awk '{print $5}' | head -n1)
    
    if [ -n "$WIRELESS_IF" ]; then
        echo "$WIRELESS_IF"
        return
    fi
    
    # If no wireless, try any active interface
    ACTIVE_IF=$(ip -o -4 route show default | awk '{print $5}' | head -n1)
    
    if [ -n "$ACTIVE_IF" ]; then
        echo "$ACTIVE_IF"
        return
    fi
    
    # If still no interface found
    echo ""
}

# Function to check if Cloudflare DNS is currently active
is_cloudflare_dns_active() {
    local interface=$1
    
    # Check if Cloudflare DNS is configured for IPv4
    if nmcli -t -f IP4.DNS device show $interface | grep -q "1.1.1.1"; then
        return 0 # True, Cloudflare DNS is active
    else
        return 1 # False, Cloudflare DNS is not active
    fi
}

# Function to set Cloudflare DNS
set_cloudflare_dns() {
    local interface=$1
    
    log "Setting Cloudflare DNS on interface $interface..."
    
    # Try to set DNS using nmcli
    if nmcli connection modify "$(nmcli -t -f NAME,DEVICE connection show --active | grep $interface | cut -d: -f1)" \
        ipv4.dns "1.1.1.1,1.0.0.1" \
        ipv6.dns "2606:4700:4700::1111,2606:4700:4700::1001"; then
        
        # Restart the connection to apply changes
        if nmcli connection up "$(nmcli -t -f NAME,DEVICE connection show --active | grep $interface | cut -d: -f1)" >/dev/null 2>&1; then
            log "Successfully set Cloudflare DNS on $interface"
            notify-send "DNS Toggle" "Switched to Cloudflare DNS (1.1.1.1)"
            return 0
        else
            log "ERROR: Failed to restart network connection"
            notify-send "DNS Toggle" "ERROR: Failed to restart network connection" --icon=dialog-error
            return 1
        fi
    else
        log "ERROR: Failed to set Cloudflare DNS"
        notify-send "DNS Toggle" "ERROR: Failed to set Cloudflare DNS" --icon=dialog-error
        return 1
    fi
}

# Function to reset DNS to default
reset_to_default_dns() {
    local interface=$1
    
    log "Resetting to default DNS on interface $interface..."
    
    # Try to reset DNS to automatic (empty)
    if nmcli connection modify "$(nmcli -t -f NAME,DEVICE connection show --active | grep $interface | cut -d: -f1)" \
        ipv4.dns "" \
        ipv6.dns ""; then
        
        # Restart the connection to apply changes
        if nmcli connection up "$(nmcli -t -f NAME,DEVICE connection show --active | grep $interface | cut -d: -f1)" >/dev/null 2>&1; then
            log "Successfully reset to default DNS on $interface"
            notify-send "DNS Toggle" "Switched to default system DNS"
            return 0
        else
            log "ERROR: Failed to restart network connection"
            notify-send "DNS Toggle" "ERROR: Failed to restart network connection" --icon=dialog-error
            return 1
        fi
    else
        log "ERROR: Failed to reset DNS"
        notify-send "DNS Toggle" "ERROR: Failed to reset DNS" --icon=dialog-error
        return 1
    fi
}

# Main function
main() {
    # Get active interface
    ACTIVE_IF=$(get_active_interface)
    
    if [ -z "$ACTIVE_IF" ]; then
        log "ERROR: No active network interface found"
        notify-send "DNS Toggle" "ERROR: No active network interface found" --icon=dialog-error
        exit 1
    fi
    
    log "Active network interface: $ACTIVE_IF"
    
    # Check if Cloudflare DNS is already active
    if is_cloudflare_dns_active "$ACTIVE_IF"; then
        log "Cloudflare DNS is currently active. Switching to default DNS..."
        reset_to_default_dns "$ACTIVE_IF"
    else
        log "Default DNS is currently active. Switching to Cloudflare DNS..."
        set_cloudflare_dns "$ACTIVE_IF"
    fi
}

# Run the main function
main
