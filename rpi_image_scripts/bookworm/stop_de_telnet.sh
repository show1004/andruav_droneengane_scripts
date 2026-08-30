#!/bin/bash

# Color definitions for terminal output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Script to stop the DroneEngage telnet module service (no autostart change)

echo -e "${YELLOW}Stopping de_telnet.service...${NC}"

# Stop de_telnet.service
echo -e "${BLUE}Stopping de_telnet.service...${NC}"
if sudo systemctl stop de_telnet.service; then
  echo -e "${GREEN}de_telnet.service stopped successfully.${NC}"
else
  echo -e "${RED}Failed to stop de_telnet.service.${NC}"
fi

echo -e "${GREEN}de_telnet.service stopped.${NC}"

#User Info
echo -e "${YELLOW}This script stops the following service:${NC}"
echo -e "${BLUE} - de_telnet.service${NC}"
echo -e "${YELLOW}This service runs the DroneEngage telnet module.${NC}"
echo -e "${YELLOW}This does not change its AutoStart setting.${NC}"
