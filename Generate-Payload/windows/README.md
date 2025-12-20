# Slot  Tool
This tool help you to get the Shell in windows environment.

## Feature's
- AMSI Bypass
- Random Generated payload in .ps1 file.
- Automate the process
- Fast and Reliable

## Insipiration
xct

## Help
```bash
└─# bash Slot.sh -h 
PowerShell Payload Generator
====================================

USAGE:
  Slot.sh [OPTIONS]

OPTIONS:
  --lhost IP       Listener IP address (required)
  --lport PORT     Listener port (required)
  --sport PORT     HTTP server port (required)
  -h, --help       Show this help message

EXAMPLES:
  Slot.sh --lhost 10.10.x.x --lport 443 --sport 8080
  Slot.sh --lhost 192.168.x.x --lport 9001 --sport 8000

NOTES:
  • Use Ctrl+C to stop the server and cleanup
  • Start listener: rlwrap nc -lvnp <LPORT>
  • Files created: touch.ps1, cradle, payload.txt
```
## Example
```bash
./Slot.sh --lhost 192.168.x.x --lport 9001 --sport 8000
```
