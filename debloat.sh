#!/bin/bash

echo "Samsung Debloat Script by invinciblevenom"

# Function to show usage
show_usage() {
    echo "Usage: $0 MODE"
    echo "Modes:"
    echo "  1, l, light  - Light debloat (basic removal of non-essential apps)"
    echo "  2, m, medium - Medium debloat (light + additional removals)"
    echo "  3, h, heavy  - Heavy debloat (medium + most aggressive removals)"
    exit 1
}

# Function to read package list from file
read_package_list() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo "Error: Package list $file not found"
        exit 1
    fi
    
    # Read file and filter out comments and empty lines
    grep -v '^#' "$file" | grep -v '^$'
}

# Check if adb is installed
if ! command -v adb &> /dev/null; then
    echo "Error: adb is not installed"
    exit 1
fi

# Check for argument
if [ $# -ne 1 ]; then
    show_usage
fi

# Initialize arrays for package lists
declare -a package_lists

# Determine which package lists to use based on argument
case $1 in
    1|l|light)
        echo "Selected: Light debloat"
        package_lists=("packages/light.list")
        ;;
    2|m|medium)
        echo "Selected: Medium debloat"
        package_lists=("packages/light.list" "packages/medium.list")
        ;;
    3|h|heavy)
        echo "Selected: Heavy debloat"
        package_lists=("packages/light.list" "packages/medium.list" "packages/heavy.list")
        ;;
    *)
        show_usage
        ;;
esac

# Start ADB server and check for devices
echo "Starting ADB server..."
adb devices

# Read and process each package list
declare -A all_packages  # Associative array to store unique packages
for list in "${package_lists[@]}"; do
    echo "Processing package list: $list"
    while IFS= read -r package || [ -n "$package" ]; do
        # Skip empty lines and comments
        [[ -z "$package" || "$package" =~ ^#.*$ ]] && continue
        
        # Store package in associative array (this automatically handles duplicates)
        all_packages["$package"]=1
    done < <(read_package_list "$list")
done

# Initialize counters
total_packages=${#all_packages[@]}
successful_removals=0
failed_removals=0
declare -A failed_packages  # Store failed packages and their reasons

# Print total packages to be removed
echo "Total packages to remove: $total_packages"

# Uninstall each package and track results
current=0
for package in "${!all_packages[@]}"; do
    ((current++))
    echo -n "[$current/$total_packages] Uninstalling $package... "
    
    # Capture the output and exit status of the uninstall command
    output=$(adb shell pm uninstall --user 0 "$package" 2>&1)
    status=$?
    
    # Check if the operation was successful
    if [[ $output == *"Success"* ]]; then
        echo "Success"
        ((successful_removals++))
    else
        echo "Failed: $output"
        ((failed_removals++))
        failed_packages["$package"]="$output"
    fi
done

# Reinstall essential packages
echo -e "\nReinstalling essential packages..."
adb shell cmd package install-existing com.sec.android.soagent
adb shell cmd package install-existing com.sec.android.systemupdate

# Kill ADB server
echo "Killing adb server..."
adb kill-server

# Print summary
echo -e "\n\n=== Debloating Summary ==="
echo "Total packages processed: $total_packages"
echo "Successful removals: $successful_removals"
echo "Failed removals: $failed_removals"

# Print failed packages if any
if [ $failed_removals -gt 0 ]; then
    echo -e "\nFailed packages:"
    for package in "${!failed_packages[@]}"; do
        echo "- $package: ${failed_packages[$package]}"
    done
fi

# Calculate success rate
success_rate=$(awk "BEGIN {printf \"%.1f\", ($successful_removals * 100 / $total_packages)}")
echo -e "\nSuccess rate: $success_rate%"
echo -e "(NOTE: Some packages may not have been isntalled in the first place,"
echo -e "or may have been removed prior. 100% success rate is not to be expected.)"
echo -e "\nDebloating complete!"