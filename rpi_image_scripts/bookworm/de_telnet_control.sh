#!/bin/bash

# Color definitions for terminal output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Wrapper that dispatches DroneEngage telnet module (de_telnet) actions.
# Usage: de_telnet_control.sh {enable|restart|stop|disable}
#
# WARNING: de_telnet exposes a remote terminal on the DroneEngage bus.
# Only enable if you know what you are doing.

ACTION="${1:-}"

case "$ACTION" in
    enable)
        echo -e "${YELLOW}Enable and start de_telnet...${NC}"
        echo -e "${YELLOW}WARNING: This exposes a remote terminal. Only enable if you know what you are doing.${NC}"
        exec /home/pi/scripts/enable_and_restart_de_telnet.sh
        ;;
    restart)
        echo -e "${YELLOW}Restart de_telnet...${NC}"
        exec /home/pi/scripts/restart_de_telnet.sh
        ;;
    stop)
        echo -e "${YELLOW}Stop de_telnet...${NC}"
        exec /home/pi/scripts/stop_de_telnet.sh
        ;;
    disable)
        echo -e "${YELLOW}Disable and stop de_telnet...${NC}"
        exec /home/pi/scripts/disable_de_telnet.sh
        ;;
    *)
        echo -e "${RED}Unknown action: '${ACTION}'${NC}"
        echo -e "${YELLOW}Usage: de_telnet_control.sh {enable|restart|stop|disable}${NC}"
        exit 1
        ;;
esac
