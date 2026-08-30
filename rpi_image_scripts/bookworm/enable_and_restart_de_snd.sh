#!/bin/bash

# Color definitions for terminal output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Script to enable and start the DroneEngage sound module service

echo -e "${YELLOW}Enabling and starting de_snd.service...${NC}"

# Enable and start de_snd.service
echo -e "${BLUE}Enabling and starting de_snd.service...${NC}"
if sudo systemctl unmask de_snd.service && sudo systemctl enable de_snd.service && sudo systemctl start de_snd.service; then
  echo -e "${GREEN}de_snd.service enabled and started successfully.${NC}"
else
  echo -e "${RED}Failed to enable and start de_snd.service.${NC}"
fi

echo -e "${GREEN}de_snd.service enabled and started.${NC}"

#User Info
echo -e "${YELLOW}This script enables and starts the following service:${NC}"
echo -e "${BLUE} - de_snd.service${NC}"
echo -e "${YELLOW}This service runs the DroneEngage sound module.${NC}"
