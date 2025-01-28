#!/bin/bash

# Default values
ANIMATION_SCALE=0.35
BATTERY_OPTIMIZATION=true
LOCATION_OPTIMIZATION=true
PERFORMANCE_OPTIMIZATION=true
GOS_DISABLE=true

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -a, --animation SCALE    Set animation scale (default: 0.35)"
    echo "  -b, --no-battery        Skip battery optimizations"
    echo "  -l, --no-location       Skip location optimizations"
    echo "  -p, --no-performance    Skip performance optimizations"
    echo "  -g, --no-gos           Skip Game Optimizing Service (GOS) disable"
    echo "  -h, --help             Show this help message"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--animation)
            ANIMATION_SCALE="$2"
            shift 2
            ;;
        -b|--no-battery)
            BATTERY_OPTIMIZATION=false
            shift
            ;;
        -l|--no-location)
            LOCATION_OPTIMIZATION=false
            shift
            ;;
        -p|--no-performance)
            PERFORMANCE_OPTIMIZATION=false
            shift
            ;;
        -g|--no-gos)
            GOS_DISABLE=false
            shift
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            ;;
    esac
done

echo "Tweaks Script - jackinthebox52"
echo "Inspired by https://github.com/invinciblevenom/samsung-debloater"
echo "=============================================\n\n"

# Check if adb is installed
if ! command -v adb &> /dev/null; then
    echo "Error: adb is not installed"
    exit 1
fi

# Check for connected devices
echo "Checking connected devices"
adb devices

# Apply battery optimizations
if [ "$BATTERY_OPTIMIZATION" = true ]; then
    echo "Applying battery optimizations..."
    adb shell settings put global adaptive_battery_management_enabled 0
    adb shell settings put global cached_apps_freezer enabled
    adb shell settings put global protect_battery 1
    adb shell settings put secure send_action_app_error 0
fi

# Apply location optimizations
if [ "$LOCATION_OPTIMIZATION" = true ]; then
    echo "Applying location optimizations..."
    adb shell settings put global assisted_gps_enabled 1
    adb shell settings put global wifi_scan_always_enabled 1
fi

# Apply performance optimizations
if [ "$PERFORMANCE_OPTIMIZATION" = true ]; then
    echo "Applying performance optimizations..."
    adb shell settings put global animator_duration_scale $ANIMATION_SCALE
    adb shell settings put global transition_animation_scale $ANIMATION_SCALE
    adb shell settings put global window_animation_scale $ANIMATION_SCALE
    adb shell settings put global ram_expand_size 0
    adb shell settings put global zram_enabled 0
    adb shell settings put global online_manual_url 0
    adb shell settings put global bug_report 0
    adb shell settings put global debug_app 0
fi

# Disable GOS
if [ "$GOS_DISABLE" = true ]; then
    echo "Disabling Game Optimizing Service (GOS)..."
    adb shell pm disable-user --user 0 com.samsung.android.game.gos
    adb shell pm clear --user 0 com.samsung.android.game.gos
    adb shell settings put secure game_auto_temperature_control 0
fi

# Kill ADB server
echo "Killing adb server..."
adb kill-server

echo "All optimizations complete!"