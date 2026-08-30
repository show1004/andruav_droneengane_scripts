#!/bin/bash

# Color definitions for terminal output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Wrapper that dispatches DroneEngage collective service actions.
# Usage: de_service_control.sh {enable|disable|restart|stop}

ACTION="${1:-}"

case "$ACTION" in
    enable)
        echo -e "${YELLOW}Enable and start DroneEngage services...${NC}"
        exec /home/pi/scripts/enable_and_restart_services.sh
        ;;
    disable)
        echo -e "${YELLOW}Disable and stop DroneEngage services...${NC}"
        exec /home/pi/scripts/disable_droneengage_service.sh
        ;;
    restart)
        echo -e "${YELLOW}Restart DroneEngage services...${NC}"
        exec /home/pi/scripts/restart_droneengage_services.sh
        ;;
    stop)
        echo -e "${YELLOW}Stop DroneEngage services...${NC}"
        exec /home/pi/scripts/stop_droneengage_services.sh
        ;;
    *)
        echo -e "${RED}Unknown action: '${ACTION}'${NC}"
        echo -e "${YELLOW}Usage: de_service_control.sh {enable|disable|restart|stop}${NC}"
        exit 1
        ;;
esac
