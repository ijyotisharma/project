#!/bin/bash
# ====================================================
# AWS EC2 Health Check Script (CentOS/Linux)
# Saves results into a timestamped log file
# ====================================================

LOG_DIR = "/var/log/ec2_health"
mkdir -p $LOG_DIR
LOG_FILE = "$LOG_DIR/HealthCHECK_$(date +%Y%m%d_%H%M%S).log"

echo "------------------------------------------------" | tee -a $LOG_FILE
echo "AWS EC2 Health Check Report - $(date)" | tee -a $LOG_FILE
echo "------------------------------------------------" | tee -a $LOG_FILE


# Host Details
echo -e "\n ---------System Info ------" |tee -a $LOG_FILE
echo "Hostname: $(hostname)" | tee -a $LOG_FILE
echo "Host IP: $(hostname -I)" | tee -a $LOG_FILE
echo "Public Interface IP: $(ip addr show eth0| grep 'inet' | awk '{print $2}')" |tee -a $LOG_FILE


echo "Uptime: $(uptime)" |tee -a $LOG_FILE
echo "Uptime: $(uptime -p)" | tee -a $LOG_FILE

#CPU and Memory
echo -e "\n------- CPU AND MEMORY -----------"| tee -a $LOG_FILE
echo "CPU Load : $(uptime)" | tee -a $LOG_FILE
echo "vmstat: "| tee -a $LOG_FILE
vmstat 2 2 | tee -a $LOG_FILE
echo "Memory: $(free -h)"| tee -a $LOG_FILE
echo "Top 5 memory hogging process: " | tee -a $LOG_FILE
ps -eo pod | head -n 5 |  tee -a $LOG_FILE


# Swap
echo -e "\n---- Swap Memory ----" | tee -a $LOG_FILE
swapon --show | tee -a $LOG_FILE
free -m | grep Swap | tee -a $LOG_FILE
echo "Swap memory: $(free -h | grep -i swap)" | tee -a $LOG_FILE

# Disk
echo -e "\n---- Disk / Volumes ----" | tee -a $LOG_FILE
lsblk | tee -a $LOG_FILE
df -h | tee -a $LOG_FILE
echo "Inodes usage:" | tee -a $LOG_FILE
df -i | tee -a $LOG_FILE

# Network
echo -e "\n---- Network ----" | tee -a $LOG_FILE
echo "Default Route:" | tee -a $LOG_FILE
ip route | tee -a $LOG_FILE
echo "DNS Resolution Test:" | tee -a $LOG_FILE
nslookup google.com 2>&1 | tee -a $LOG_FILE
echo "Active Connections:" | tee -a $LOG_FILE
ss -tulnp | tee -a $LOG_FILE

# Logs
echo -e "\n---- Logs ----" | tee -a $LOG_FILE
echo "System Errors (last 50 lines):" | tee -a $LOG_FILE
journalctl -p 3 -n 50 --no-pager | tee -a $LOG_FILE
echo "Messages log errors:" | tee -a $LOG_FILE
grep -i "error" /var/log/messages | tail -n 20 | tee -a $LOG_FILE
echo "Syslog errors:" | tee -a $LOG_FILE
[ -f /var/log/syslog ] && grep -i "error" /var/log/syslog | tail -n 20 | tee -a $LOG_FILE

# Security
echo -e "\n---- Security ----" | tee -a $LOG_FILE
echo "Logged-in users:" | tee -a $LOG_FILE
who | tee -a $LOG_FILE
echo "Last logins:" | tee -a $LOG_FILE
last -n 5 | tee -a $LOG_FILE
echo "Failed SSH attempts:" | tee -a $LOG_FILE
grep "Failed password" /var/log/secure | tail -n 10 | tee -a $LOG_FILE

# Services
echo -e "\n---- Services ----" | tee -a $LOG_FILE
systemctl --failed | tee -a $LOG_FILE

echo -e "\n✅ Health check complete. Log saved at: $LOG_FILE"
