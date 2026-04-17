#!/bin/bash
# health-data-manager - Health Data Management Script

# Data directory
DATA_DIR="/root/hiclaw-fs/shared/projects/health-system/data"
mkdir -p "${DATA_DIR}"

# Function to log
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Initialize data structure
init_data() {
    log "Initializing health data structure..."
    
    # Create subdirectories
    mkdir -p "${DATA_DIR}/exercise"
    mkdir -p "${DATA_DIR}/diet"
    mkdir -p "${DATA_DIR}/sleep"
    mkdir -p "${DATA_DIR}/body-weight"
    
    # Create default data file
    cat > "${DATA_DIR}/config.json" << EOF
{
  "project_id": "health-system",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "settings": {
    "unit_system": "metric",
    "time_zone": "Asia/Shanghai",
    "goals": {
      "daily_steps": 10000,
      "weekly_workout_days": 5,
      "daily_calories": 2000
    }
  }
}
EOF
    
    log "Data structure initialized!"
    echo ""
    echo "Data directories created:"
    echo "  - ${DATA_DIR}/exercise"
    echo "  - ${DATA_DIR}/diet"
    echo "  - ${DATA_DIR}/sleep"
    echo "  - ${DATA_DIR}/body-weight"
    echo ""
    echo "Config file: ${DATA_DIR}/config.json"
}

# Display help
show_help() {
    echo "Health Data Manager"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  init      Initialize data structure"
    echo "  help      Show this help message"
    echo ""
}

# Main
case "${1:-}" in
    init)
        init_data
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: ${1:-}"
        show_help
        exit 1
        ;;
esac
