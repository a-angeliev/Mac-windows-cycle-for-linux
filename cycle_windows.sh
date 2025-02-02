#!/bin/bash

# Get the list of all open windows and their window IDs (in hexadecimal format)
windows=$(wmctrl -l)

# Get the currently active window ID (in decimal format)
current=$(xdotool getactivewindow)

# Convert the current window ID from decimal to hexadecimal
current_hex=$(printf "0x%08x\n" $current)

# Initialize an empty array for filtered windows (flag 0 windows)
filtered_windows=()

# Go through each window and filter out windows with the flag -1 (non-application windows)
while IFS= read -r line; do
    window_id=$(echo "$line" | awk '{print $1}')
    state_flag=$(echo "$line" | awk '{print $2}')
    window_title=$(echo "$line" | cut -d ' ' -f 5-)

    # Skip windows that have the flag -1 (likely non-application windows like desktops)
    if [[ "$state_flag" == "-1" ]]; then
        continue
    else
        # Add only application windows (flag 0) to the filtered list
        filtered_windows+=("$window_id")
    fi
done <<< "$windows"

# If no valid windows are left after filtering, exit with an error
if [ ${#filtered_windows[@]} -eq 0 ]; then
    echo "Error: No valid windows to cycle through."
    exit 1
fi

# Debugging: Print the filtered list of windows
echo "Filtered windows: ${filtered_windows[@]}"

# Find the current window's position in the filtered list
current_index=-1
for i in "${!filtered_windows[@]}"; do
    if [ "${filtered_windows[$i]}" == "$current_hex" ]; then
        current_index=$i
        break
    fi
done

# If the current window is not found, exit with an error
if [ "$current_index" -eq -1 ]; then
    echo "Error: Current window not found in the list."
    exit 1
fi

# Calculate the index of the next window (next window in the filtered list)
next_index=$((current_index + 1))

# If the current window is the last one in the filtered list, cycle back to the first window
if [ "$next_index" -ge "${#filtered_windows[@]}" ]; then
    next_index=0
fi

# Get the ID of the next window to cycle to
next_window="${filtered_windows[$next_index]}"

# Switch to the next window
wmctrl -ia "$next_window"

# Debugging output to see which window is being activated
echo "Current window: $current_hex"
echo "Next window: $next_window"

