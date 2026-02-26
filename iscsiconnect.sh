#!/bin/bash
# iSCSI Console Manager - Ubuntu 22.04/24.04
# iscsi_conmanager v1.5 | by Qvert.net
[[ $EUID -ne 0 ]] && echo "Error: Run as root" && exit 1

# --- Color Codes ---
CLR_BANNER='\033[1;96m'   # Cyan (Branding)
CLR_SETUP='\033[1;92m'    # Green (Preparation)
CLR_CONN='\033[1;93m'     # Yellow (Active Operations)
CLR_ADV='\033[1;95m'      # Magenta (Configuration)
CLR_MAINT='\033[1;97m'    # White (Maintenance)
CLR_INFO='\033[1;96m'     # Cyan (Info/Exit)
RESET='\033[0m'

print_banner() {
    echo -e "${CLR_BANNER}======================================================================"
    echo -e "  ██████╗ ██╗   ██╗███████╗██████╗ ████████╗"
    echo -e " ██╔═══██╗██║   ██║██╔════╝██╔══██╗╚══██╔══╝"
    echo -e " ██║   ██║██║   ██║█████╗  ██████╔╝   ██║   "
    echo -e " ██║▄▄ ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗   ██║   "
    echo -e " ╚██████╔╝ ╚████╔╝ ███████╗██║  ██║   ██║   "
    echo -e "  ╚══▀▀═╝   ╚═══╝  ╚═════╝ ╚═════╝    ╚═╝   "
    echo -e "  iscsi_conmanager v1.5 | by Qvert.net"
    echo -e "======================================================================${RESET}"
}

# --- Core & Network (Green) ---
cmd_install() { apt update && apt install open-iscsi -y && systemctl enable --now iscsid; }
cmd_firewall() { command -v ufw >/dev/null || apt install ufw -y; ufw --force enable; ufw allow 3260/tcp comment 'iSCSI-In'; ufw allow out 3260/tcp comment 'iSCSI-Out'; ufw reload; echo -e "${CLR_SETUP}UFW configured${RESET}"; }
cmd_network() { echo -e "${CLR_SETUP}--- Network ---${RESET}"; ip -br addr show | grep -v lo; ip route | grep default; hostname; }
cmd_ping() { read -p "Target IP: " ip; ping -c 3 "$ip" && echo -e "${CLR_SETUP}Reachable${RESET}" || echo -e "${CLR_SETUP}Unreachable${RESET}"; }

# --- Connection Mgmt (Yellow) ---
cmd_discover() { read -p "Target IP: " ip; iscsiadm -m discovery -t sendtargets -p "$ip"; }
cmd_login() { read -p "IQN: " iqn; read -p "Target IP: " ip; iscsiadm -m node -T "$iqn" -p "$ip" -l; }
cmd_logout() { read -p "IQN: " iqn; read -p "Target IP: " ip; iscsiadm -m node -T "$iqn" -p "$ip" -u; }
cmd_sessions() { iscsiadm -m session; }

# --- Advanced Features (Magenta) ---
cmd_chap() { read -p "IQN: " iqn; read -p "Username: " user; read -sp "Password: " pass; echo; iscsiadm -m node -T "$iqn" -o update -n discovery.sendtargets.auth.username -v "$user"; iscsiadm -m node -T "$iqn" -o update -n discovery.sendtargets.auth.password -v "$pass"; iscsiadm -m node -T "$iqn" -o update -n node.session.auth.username -v "$user"; iscsiadm -m node -T "$iqn" -o update -n node.session.auth.password -v "$pass"; echo -e "${CLR_ADV}CHAP configured${RESET}"; }
cmd_persist() { read -p "IQN: " iqn; read -p "Auto Login (yes/no): " ans; val="manual"; [[ "$ans" == "yes" ]] && val="automatic"; iscsiadm -m node -T "$iqn" -o update -n node.startup -v "$val"; echo -e "${CLR_ADV}Persistence set to $val${RESET}"; }
cmd_rescan() { for host in /sys/class/scsi_host/host*; do echo "- - -" > "$host/scan"; done; echo -e "${CLR_ADV}Bus Rescan Complete${RESET}"; }
cmd_multipath() { apt install multipath-tools -y; mpathconf --enable --with_multipathd y; systemctl enable --now multipathd; echo -e "${CLR_ADV}Multipath Enabled${RESET}"; }

# --- Maintenance (White) ---
cmd_iostat() { command -v iostat >/dev/null || apt install sysstat -y; iostat -x 1 3; }
cmd_unmount() { mount | grep "/dev/sd" | awk '{print $3}' | while read mnt; do umount "$mnt"; echo "Unmounted $mnt"; done; echo -e "${CLR_MAINT}Safe Unmount Complete${RESET}"; }
cmd_backup() { tar -czf "/root/iscsi_cfg_$(date +%F_%H%M).tar.gz" /etc/iscsi; echo -e "${CLR_MAINT}Backup Saved to /root/${RESET}"; }
cmd_cleanup() { read -p "Delete ALL nodes? (yes/no): " ans; [[ "$ans" == "yes" ]] && iscsiadm -m node -o delete && echo -e "${CLR_MAINT}Nodes Deleted${RESET}" || echo "Cancelled"; }

# --- Info & Exit (Cyan) ---
cmd_timeout() { read -p "IQN: " iqn; read -p "Timeout (sec): " sec; iscsiadm -m node -T "$iqn" -o update -n node.session.timeouts.replacement_timeout -v "$sec"; echo -e "${CLR_INFO}Timeout Updated${RESET}"; }
cmd_validate() { echo -e "${CLR_INFO}--- Devices ---${RESET}"; lsblk -o NAME,SIZE,TYPE,MOUNTPOINT; echo -e "${CLR_INFO}--- Logs ---${RESET}"; dmesg | tail -n 10; }

# --- Full Workflow Diagram (Restored) ---
cmd_workflow() {
    echo -e "${CLR_BANNER}"
    cat << 'DIAGRAM'
┌─────────────────────────────────────────────────────────────────────────┐
│                    iSCSI Console Manager v1.5                           │
│                         by Qvert.net                                    │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │   START (Root Privileges)     │
                    └───────────────────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │      Main Menu Loop           │
                    └───────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        ▼                           ▼                           ▼
┌───────────────┐          ┌───────────────┐          ┌───────────────┐
│ 1. Install    │          │ 2. Firewall   │          │ 3. Network    │
│   iSCSI       │          │   Config      │          │   Info        │
└───────────────┘          └───────────────┘          └───────────────┘
        │                           │                           │
        ▼                           ▼                           ▼
  • apt update              • Check ufw                  • ip addr show
  • install open-iscsi      • Install if missing         • ip route
  • enable iscsid           • allow 3260/tcp             • DNS servers
                            • reload rules
        │                           │                           │
        └───────────────────────────┴───────────────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │    iSCSI Connection Flow      │
                    └───────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        ▼                           ▼                           ▼
┌───────────────┐          ┌───────────────┐          ┌───────────────┐
│ 5. Discover   │───────▶  │ 6. Login      │          │ 7. Logout     │
│   Target      │          │   Target      │          │   Target      │
└───────────────┘          └───────────────┘          └───────────────┘
        │                           │                           │
        ▼                           ▼                           ▼
  • Input Target IP         • Input IQN                  • Input IQN
  • iscsiadm discovery      • iscsiadm login             • iscsiadm logout
  • Shows available         • Creates /dev/sdX           • Removes device
    targets                 • Persistent if enabled
        │                           │                           │
        └───────────────────────────┴───────────────────────────┘
                                    │
                                    ▼
        ┌───────────────────────────┼───────────────────────────┐
        ▼                           ▼                           ▼
┌───────────────┐          ┌───────────────┐          ┌───────────────┐
│ 8. Sessions   │          │ 18. Validate  │          │ 20. Exit      │
│   (Active)    │          │   Storage     │          │   Cleanly     │
└───────────────┘          └───────────────┘          └───────────────┘
        │                           │
        ▼                           ▼
  • iscsiadm -m session       • lsblk (devices)
  • Show active connections   • dmesg (kernel logs)

--- USE CASE SUMMARY ---
+----+------------------+---------------------------+---------------------------+
| #  | Feature          | Use Case                  | When to Use               |
+----+------------------+---------------------------+---------------------------+
| 1  | Install iSCSI    | Initial setup             | Fresh Ubuntu system       |
| 2  | Config Firewall  | Open port 3260            | Before connecting         |
| 3  | Network Info     | View IP/route/DNS         | Identify source interface |
| 5  | Discover         | Find available targets    | Enumerate storage         |
| 6  | Login            | Connect to target         | Mount remote block storage|
| 7  | Logout           | Disconnect target         | Safe removal              |
| 9  | CHAP Auth        | Security                  | Target requires auth      |
| 10 | Persistence      | Boot Login                | Survive reboot            |
| 12 | Multipath        | Redundancy                | Multiple paths to target  |
| 15 | Backup Config    | Recovery                  | Before major changes      |
+----+------------------+---------------------------+---------------------------+
DIAGRAM
    echo -e "${RESET}"
}

while true; do
    clear
    print_banner
    echo -e "${CLR_SETUP}1) Install iSCSI      2) Firewall           3) Network Info       4) Ping Target${RESET}"
    echo -e "${CLR_CONN}5) Discover           6) Login              7) Logout             8) Sessions${RESET}"
    echo -e "${CLR_ADV}9) CHAP Auth          10) Persistence       11) Rescan Bus        12) Multipath${RESET}"
    echo -e "${CLR_MAINT}13) IO Stats          14) Safe Unmount      15) Backup Config     16) Cleanup Nodes${RESET}"
    echo -e "${CLR_INFO}17) Tune Timeouts     18) Validate          19) Workflow Diagram  20) Exit${RESET}"
    echo -ne "${CLR_BANNER}Option: ${RESET}"
    read opt
    case $opt in
        1) cmd_install ;; 2) cmd_firewall ;; 3) cmd_network ;; 4) cmd_ping ;;
        5) cmd_discover ;; 6) cmd_login ;; 7) cmd_logout ;; 8) cmd_sessions ;;
        9) cmd_chap ;; 10) cmd_persist ;; 11) cmd_rescan ;; 12) cmd_multipath ;;
        13) cmd_iostat ;; 14) cmd_unmount ;; 15) cmd_backup ;; 16) cmd_cleanup ;;
        17) cmd_timeout ;; 18) cmd_validate ;; 19) cmd_workflow ;; 20) exit 0 ;;
        *) echo -e "${CLR_BANNER}Invalid${RESET}" ;;
    esac
    echo -ne "${CLR_BANNER}Press Enter to continue...${RESET}"
    read
done