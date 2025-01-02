# 🕒 Cron Job Manager

This is a learning project I created while getting into shell scripting. I was exploring different bash concepts and thought it would be cool to build something practical. While it's not perfect, it helped me understand a lot about shell scripting and cron jobs!

This is my attempt at making cron job management a bit easier. It's not perfect, and there's probably better ways to do some things.

## 🚀 Features

- List all your cron jobs with human-readable descriptions
- Add new jobs without messing with crontab syntax
- Edit or remove existing jobs
- Backup and restore functionality (saved my bacon a few times)
- Search through your jobs
- Track execution history
- Comes with some example jobs to get you started

## 📋 Requirements

- Bash shell
- Unix-like operating system (Linux, macOS)
- Access to crontab

## 🛠️ Installation

1. Clone this repo:
```bash
git clone https://github.com/yashikaadesai/Cron-Job-Manager.git
cd cron-manager
```

2. Make the script executable:
```bash
chmod +x cron_manager.sh
```

## 🎮 Usage

Just run the script:
```bash
./cron_manager.sh
```

You'll get a menu with these options:
1. List cron jobs
2. Add a new job
3. Edit existing job
4. Remove a job
5. Backup jobs
6. Restore from backup
7. Search jobs
8. View history
9. Help
10. Exit

## 📝 Example Jobs

The script comes with some example jobs to show you how it works:
- Daily database backup at 2 AM
- System health check every 10 minutes
- Project compilation at 5 PM
- Monday morning reminder emails

## 🤔 Common Issues & Solutions

**Error: "bad minute" when adding jobs**
- Make sure to use proper cron format (e.g., `0 8 * * *` not "8AM")

**Can't see any jobs**
- Check if you have proper permissions
- Try running `crontab -l` directly

Known limitations:
- The time display format could be more consistent
- Error handling could be more robust
- Some edge cases might not be handled perfectly
