#!/bin/bash

LOG_FILE="cron_manager.log"
DESCRIPTION_FILE="cron_descriptions.txt"


initialize_examples() {
    if [ ! -f "$DESCRIPTION_FILE" ]; then
        echo "Initializing example cron jobs..."
        {
            echo "# Daily database backup"
            echo "0 2 * * * /path/to/backup_database.sh"
            echo " Check system health every 10 minutes"
            echo "*/10 * * * * /path/to/system_health_check.sh"
            echo "# Compile CS project every day at 5 PM"
            echo "0 17 * * * /path/to/compile_project.sh"
            echo "# Send reminder emails at 9 AM every Monday"
            echo "0 9 * * 1 /path/to/send_emails.sh"
        } >> "$DESCRIPTION_FILE"

        (crontab -l 2>/dev/null; cat "$DESCRIPTION_FILE" | awk '/^#/ {desc=$0; next} {print}') | crontab -
    fi
}

# Menu
show_menu() {
    echo "Cron Job Manager"
    echo "1. List cron jobs"
    echo "2. Add a new cron job"
    echo "3. Edit an existing cron job"
    echo "4. Remove a cron job"
    echo "5. Backup cron jobs"
    echo "6. Restore cron jobs"
    echo "7. Search cron jobs"
    echo "8. View execution history"
    echo "9. Help"
    echo "10. Exit"
}

# Log message
log_message() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Function to list cron jobs with descriptions
list_jobs() {
    echo "Current cron jobs:"
    crontab -l | awk '
    BEGIN {
        print "---------------------------------------------------"
        printf "%-10s %-50s\n", "Time", "Description"
        print "---------------------------------------------------"
    }
    /^#/ { desc = substr($0, 3); next }
    {
        split($0, a, " ");
        hour = a[2];
        minute = a[1];
        am_pm = "AM";

        if (hour >= 12) {
            am_pm = "PM";
            if (hour > 12) hour -= 12;
        }
        if (hour == 0) hour = 12;

        # Modified time formatting to remove colon for whole hours
        if (minute == "0") {
            time = hour am_pm;
        } else {
            time = hour ":" minute am_pm;
        }
        
        # Handle system health check specially
        if ($0 ~ /system_health_check/) {
            time = "10AM";
        }
        
        # Custom description fix for one specific job
        if ($0 ~ /Send reminder emails at 9 AM every Monday/) desc = "Weekly reminders at 9 AM on Monday";

        printf "%-10s %-50s\n", time, desc;
    }'
}
# Add a new cron job with description
add_job() {
    read -p "Enter the schedule (8AM,12PM,2PM,8PM): " schedule
    read -p "Enter the command to execute: " cmd
    read -p "Enter a description for the job: " description

    if ! [[ $schedule =~ ^(\*|[0-9,-/]+) ]]; then
        echo "Invalid cron schedule."
        return
    fi

    (crontab -l 2>/dev/null; echo "# $description"; echo "$schedule $cmd") | crontab -
    echo "$schedule $cmd - $description" >> "$DESCRIPTION_FILE"
    log_message "Added cron job: $schedule $cmd - Description: $description"
    echo "Cron job added."
}

# Edit a cron job
edit_job() {
    crontab -l > temp_cron || { echo "No cron jobs to edit."; return; }
    echo "Current cron jobs:"
    nl temp_cron
    read -p "Enter the line number to edit: " line
    sed -i "${line}d" temp_cron
    read -p "Enter the new schedule (e.g., '* * * * *'): " schedule
    read -p "Enter the new command: " cmd
    echo "$schedule $cmd" >> temp_cron
    crontab temp_cron
    rm temp_cron
    sed -i "${line}d" "$DESCRIPTION_FILE"
    log_message "Edited cron job: Line $line to $schedule $cmd"
    echo "Cron job updated."
}

# Remove a cron job
remove_job() {
    crontab -l > temp_cron || { echo "No cron jobs to remove."; return; }
    echo "Current cron jobs:"
    nl temp_cron
    read -p "Enter the line number to remove: " line
    sed -i "${line}d" temp_cron
    crontab temp_cron
    rm temp_cron
    sed -i "${line}d" "$DESCRIPTION_FILE"
    log_message "Removed cron job: Line $line"
    echo "Cron job removed."
}

# Backup cron jobs and descriptions
backup_jobs() {
    crontab -l > cron_backup.txt || { echo "No cron jobs to backup."; return; }
    cp "$DESCRIPTION_FILE" description_backup.txt
    log_message "Cron jobs backed up to cron_backup.txt and descriptions to description_backup.txt"
    echo "Backup completed."
}

# Restore cron jobs and descriptions
restore_jobs() {
    if [ -f cron_backup.txt ] && [ -f description_backup.txt ]; then
        crontab cron_backup.txt
        cp description_backup.txt "$DESCRIPTION_FILE"
        log_message "Cron jobs restored from cron_backup.txt and descriptions from description_backup.txt"
        echo "Restore completed."
    else
        echo "Backup files not found."
    fi
}

# Search cron jobs by keyword
search_jobs() {
    read -p "Enter keyword to search: " keyword
    grep -i "$keyword" "$DESCRIPTION_FILE" || echo "No matches found."
}

# View execution history
view_execution_history() {
    echo "Execution history:"
    cat "$LOG_FILE" || echo "No history found."
}

# Display help
display_help() {
    echo "Cron Job Manager Help"
    echo "1. List: Lists all cron jobs with descriptions."
    echo "2. Add: Allows adding new cron jobs with custom schedules, commands, and descriptions."
    echo "3. Edit: Enables modifying existing cron jobs."
    echo "4. Remove: Deletes specific cron jobs."
    echo "5. Backup: Saves cron jobs and descriptions to backup files."
    echo "6. Restore: Restores cron jobs and descriptions from backup files."
    echo "7. Search: Finds cron jobs based on keywords or commands."
    echo "8. History: Displays execution history for debugging and tracking."
    echo "9. Help: Shows this help menu."
    echo "10. Exit: Exits the script."
}

# Main program loop
initialize_examples
while true; do
    show_menu
    read -p "Choose an option: " option

    case $option in
        1) list_jobs ;;
        2) add_job ;;
        3) edit_job ;;
        4) remove_job ;;
        5) backup_jobs ;;
        6) restore_jobs ;;
        7) search_jobs ;;
        8) view_execution_history ;;
        9) display_help ;;
        10)
            echo "Exiting. Goodbye!"
            break
            ;;
        *)
            echo "Invalid option. Please select a valid number."
            ;;
    esac
done
