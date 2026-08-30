#!/bin/bash

# Color definitions for terminal output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Script to restart the DroneEngage telnet module service

echo -e "${YELLOW}Restarting de_telnet.service...${NC}"

# Restart de_telnet.service
echo -e "${BLUE}Restarting de_telnet.service...${NC}"
if sudo systemctl restart de_telnet.service; then
  echo -e "${GREEN}de_telnet.service restarted successfully.${NC}"
else
  echo -e "${RED}Failed to restart de_telnet.service.${NC}"
fi

echo -e "${GREEN}de_telnet.service restarted.${NC}"

#User Info
echo -e "${YELLOW}This script restarts the following service:${NC}"
echo -e "${BLUE} - de_telnet.service${NC}"
echo -e "${YELLOW}This service runs the DroneEngage telnet module.${NC}"
echo -e "${YELLOW}This does not change its AutoStart setting.${NC}"
