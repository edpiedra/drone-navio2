log() { 
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local calling_function=${FUNCNAME[1]:-"main"}
    local line_number=${BASH_LINENO[0]:-0}

    local formatted_message="[${timestamp}] [${SCRIPT_NAME}:${calling_function}:${line_number}] ${message}"
    printf "\n${formatted_message}\n" | tee -a "$LOG_FILE"
 }

run_step() {
    local step="$1"
    log "running $step..."
    bash "$step"
}

require_root(){
  if [[ $EUID -ne 0 ]]; then
    echo "please run $SCRIPT_NAME with sudo." >&2
    exit 1
  fi
}

ensure_line(){
  local key="$1" value="$2"
  if ! grep -q -E "^${key}=${value}$" "$BOOT_CONF"; then
    echo "${key}=${value}" >> "$BOOT_CONF"
    log "added: ${key}=${value}"
  else
    log "already present: ${key}=${value}"
  fi
}