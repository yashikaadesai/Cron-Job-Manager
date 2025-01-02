#!/bin/bash

LOG_FILE="cron_manager.log"
DESCRIPTION_FILE="cron_descriptions.txt"

# Function to display menu
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

# Function to log messages
log_message() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Function to list cron jobs with descriptions
list_jobs() {
    echo "Current cron jobs:"
    crontab -l | awk '/^#/{desc=$0; next} {printf("%s - %s\n", $0, desc); desc=""}'
}

# Function to add a new cron job with description
add_job() {
    read -p "Enter the schedule (e.g., '* * * * *'): " schedule
    read -p "Enter the command to execute: " cmd
    read -p "Enter a description for the job: " description

    # Validate cron schedule
    if ! [[ $schedule =~ ^(\*|[0-9,-/]+) ]]; then
        echo "Invalid cron schedule."
        return
    fi

    (crontab -l 2>/dev/null; echo "# $description"; echo "$schedule $cmd") | crontab -
    echo "$schedule $cmd - $description" >> "$DESCRIPTION_FILE"
    log_message "Added cron job: $schedule $cmd - Description: $description"
    echo "Cron job added."
}

# Function to remove a cron job
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

# Function to backup cron jobs and descriptions
backup_jobs() {
    crontab -l > cron_backup.txt || { echo "No cron jobs to backup."; return; }
    cp "$DESCRIPTION_FILE" description_backup.txt
    log_message "Cron jobs backed up to cron_backup.txt and descriptions to description_backup.txt"
    echo "Backup completed."
}

# Function to restore cron jobs and descriptions
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

# Function to search cron jobs by keyword
search_jobs() {
    read -p "Enter keyword to search: " keyword
    grep -i "$keyword" "$DESCRIPTION_FILE" || echo "No matches found."
}

# Function to view execution history
view_execution_history() {
    echo "Execution history:"
    cat "$LOG_FILE" || echo "No history found."
}

# Function to display help
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
