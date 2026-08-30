#!/bin/bash

# Color definitions for terminal output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Wrapper that dispatches RPI camera actions.
# Usage: de_cam_control.sh {<camera_service>|restart|stop|disable}
#   - any service name (e.g. de_camera_rpi_cam.service) -> enable + start that mode
#   - "restart" -> restart the currently active camera mode (no autostart change)
#   - "stop"    -> stop all RPI camera modes (no autostart change, resume on reboot)
#   - "disable" -> stop and disable all RPI camera modes

ACTION="${1:-}"

if [ "$ACTION" = "disable" ]; then
    echo -e "${YELLOW}Disable and stop all RPI camera modes...${NC}"
    exec /home/pi/scripts/stop_rpi_cam.sh
elif [ "$ACTION" = "stop" ]; then
    echo -e "${YELLOW}Stop all RPI camera modes (autostart unchanged)...${NC}"
    exec /home/pi/scripts/stop_rpi_cam_only.sh
elif [ "$ACTION" = "restart" ]; then
    echo -e "${YELLOW}Restart active RPI camera mode (autostart unchanged)...${NC}"
    exec /home/pi/scripts/restart_rpi_cam.sh
elif [ -n "$ACTION" ]; then
    echo -e "${YELLOW}Enable and start RPI camera mode: ${ACTION}${NC}"
    exec /home/pi/scripts/enable_and_restart_rpi_cam.sh "$ACTION"
else
    echo -e "${RED}No action specified.${NC}"
    echo -e "${YELLOW}Usage: de_cam_control.sh {<camera_service>|restart|stop|disable}${NC}"
    exit 1
fi
