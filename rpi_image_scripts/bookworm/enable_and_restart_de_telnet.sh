#!/bin/bash

# Color definitions for terminal output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Script to enable and start the DroneEngage telnet module service

echo -e "${YELLOW}Enabling and starting de_telnet.service...${NC}"
echo -e "${YELLOW}WARNING: This exposes a remote terminal on the DroneEngage bus.${NC}"
echo -e "${YELLOW}Only enable if you know what you are doing.${NC}"

# Enable and start de_telnet.service
echo -e "${BLUE}Enabling and starting de_telnet.service...${NC}"
if sudo systemctl unmask de_telnet.service && sudo systemctl enable de_telnet.service && sudo systemctl start de_telnet.service; then
  echo -e "${GREEN}de_telnet.service enabled and started successfully.${NC}"
else
  echo -e "${RED}Failed to enable and start de_telnet.service.${NC}"
fi

echo -e "${GREEN}de_telnet.service enabled and started.${NC}"

#User Info
echo -e "${YELLOW}This script enables and starts the following service:${NC}"
echo -e "${BLUE} - de_telnet.service${NC}"
echo -e "${YELLOW}This service runs the DroneEngage telnet module.${NC}"
echo -e "${YELLOW}WARNING: This exposes a remote terminal. Restrict access via allowed_users in the config.${NC}"
