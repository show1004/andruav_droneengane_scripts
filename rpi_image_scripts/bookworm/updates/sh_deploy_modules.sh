#!/bin/bash
# sh_deploy_modules.sh — Deploy release tarballs to ~/drone_engage preserving configs.
# Usage: bash sh_deploy_modules.sh <version> [module|all]
# Example: bash sh_deploy_modules.sh 20260823
#          bash sh_deploy_modules.sh 20260823 de_mavlink

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

VERSION="${1:-}"
TARGET="${2:-all}"
REL_DIR="$HOME/releases/$VERSION"
BASE="$HOME/drone_engage"
VERSION_DIR="$BASE/.versions"

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version> [module|all]"
  exit 1
fi

[[ -d "$REL_DIR" ]] || { echo -e "${RED}Release dir not found: $REL_DIR${NC}"; exit 1; }

# module -> deployed dir name (handles de_rpi_gpio -> de_gpio mapping)
declare -A DEPLOY_DIR=(
  [de_comm]="de_comm"
  [de_mavlink]="de_mavlink"
  [de_rpi_gpio]="de_gpio"
  [de_sdr]="de_sdr"
  [de_tracking]="de_tracking"
  [de_camera]="de_camera"
)

ALL_MODULES=(de_comm de_mavlink de_rpi_gpio de_sdr de_tracking de_camera)

if [[ "$TARGET" == "all" ]]; then
  MODULES="${ALL_MODULES[*]}"
else
  MODULES="$TARGET"
fi

echo -e "${BLUE}${BOLD}=== DEPLOY $VERSION → $BASE ===${NC}"
echo -e "Modules: $MODULES"
echo

failed=()
deployed=()

for mod in $MODULES; do
  deploy_dir="${DEPLOY_DIR[$mod]:-}"
  if [[ -z "$deploy_dir" ]]; then
    echo -e "${RED}Unknown module: $mod${NC}"
    failed+=("$mod"); continue
  fi

  tarball="$REL_DIR/${mod}_${VERSION}.tar.gz"
  sumfile="$REL_DIR/${mod}_${VERSION}.sha256"

  echo -e "${BLUE}${BOLD}--- Deploy: $mod → $deploy_dir/ ---${NC}"

  if [[ ! -f "$tarball" || ! -f "$sumfile" ]]; then
    echo -e "${RED}Missing tarball or checksum for $mod${NC}"
    failed+=("$mod"); continue
  fi

  # 1. Verify checksum
  (cd "$REL_DIR" && sha256sum -c "$(basename "$sumfile")" >/dev/null 2>&1) || {
    echo -e "${RED}CHECKSUM FAIL: $mod${NC}"
    failed+=("$mod"); continue
  }
  echo -e "${GREEN}Checksum OK${NC}"

  # 2. Extract to temp
  TMP=$(mktemp -d)
  tar -xzf "$tarball" -C "$TMP" || {
    echo -e "${RED}EXTRACT FAIL: $mod${NC}"
    rm -rf "$TMP"; failed+=("$mod"); continue
  }

  # The tarball contains a top-level folder named $mod (e.g. de_rpi_gpio)
  src_dir="$TMP/$mod"
  if [[ ! -d "$src_dir" ]]; then
    echo -e "${RED}Tarball top-level folder '$mod' not found${NC}"
    rm -rf "$TMP"; failed+=("$mod"); continue
  fi

  # 3. Ensure deploy dir exists
  mkdir -p "$BASE/$deploy_dir"

  # 4. Save production configs (.local and .config.module.json and root.crt)
  CONF_BK=$(mktemp -d)
  for cf in "$BASE/$deploy_dir"/*.local "$BASE/$deploy_dir"/*.config.module.json "$BASE/$deploy_dir"/root.crt "$BASE/$deploy_dir"/template.json; do
    [[ -f "$cf" ]] && cp "$cf" "$CONF_BK/" 2>/dev/null
  done

  # 5. Remove old deploy dir contents (binaries + scripts) but keep dir
  #    Actually, replace the whole dir then restore configs
  rm -rf "$BASE/$deploy_dir"
  mkdir -p "$BASE/$deploy_dir"

  # 6. Copy new files from tarball
  cp -r "$src_dir"/* "$BASE/$deploy_dir/" 2>/dev/null || true
  cp -r "$src_dir"/.* "$BASE/$deploy_dir/" 2>/dev/null || true

  # 7. Restore production configs (overwrite tarball defaults)
  for cf in "$CONF_BK"/*; do
    [[ -f "$cf" ]] && cp "$cf" "$BASE/$deploy_dir/" && echo -e "${YELLOW}Restored: $(basename "$cf")${NC}"
  done
  rm -rf "$CONF_BK"

  # 8. Permissions
  chown -R pi:pi "$BASE/$deploy_dir" 2>/dev/null || true
  find "$BASE/$deploy_dir" -type f -name 'de_*' -exec chmod +x {} \;
  find "$BASE/$deploy_dir" -type f \( -name '*.json' -o -name '*.crt' \) -exec chmod 644 {} \;

  # 9. Update version tracking
  mkdir -p "$VERSION_DIR"
  echo "$VERSION" > "$VERSION_DIR/${deploy_dir}.version"

  rm -rf "$TMP"
  echo -e "${GREEN}$mod deployed → $BASE/$deploy_dir/${NC}"
  deployed+=("$mod")
done

echo
echo -e "${BLUE}${BOLD}=== Summary ===${NC}"
if [[ ${#deployed[@]} -gt 0 ]]; then
  echo -e "${GREEN}Deployed: ${deployed[*]}${NC}"
fi
if [[ ${#failed[@]} -gt 0 ]]; then
  echo -e "${RED}Failed: ${failed[*]}${NC}"
  exit 1
fi
echo -e "${GREEN}${BOLD}✅ All modules deployed.${NC}"
