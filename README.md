
# iSCSI Console Manager

**Version:** 1.5  
**Platform:** Ubuntu 22.04 / 24.04  
**Author:** Qvert.net  
**License:** MIT

---
<img width="2731" height="1774" alt="qvert_iscsi_conmanager" src="https://github.com/user-attachments/assets/78f9ff72-1d69-436f-91e2-b37bb4407438" />

## Overview

iSCSI Console Manager is a comprehensive bash-based utility for managing iSCSI initiator connections on Ubuntu systems. It provides a color-coded menu interface for installation, configuration, connection management, and maintenance of iSCSI storage devices.

---

## Features

| Category | Options | Description |
|----------|---------|-------------|
| **Setup & Network** | 1-4 | Install iSCSI, configure firewall, view network info, ping targets |
| **Connection Management** | 5-8 | Discover targets, login/logout, view active sessions |
| **Advanced Configuration** | 9-12 | CHAP authentication, persistence, bus rescan, multipath |
| **Maintenance** | 13-16 | IO statistics, safe unmount, backup configuration, cleanup nodes |
| **Information & Exit** | 17-20 | Tune timeouts, validate devices, view workflow, exit |

---

## Installation

### Requirements

- Ubuntu 22.04 LTS or 24.04 LTS
- Root privileges
- Internet connectivity (for package installation)

### Quick Start

```bash
# Download the script
wget https://raw.githubusercontent.com/qvertnet/iscsi_conmanager/main/iscsi_menu.sh

# Make executable
chmod +x iscsi_menu.sh

# Run with root privileges
sudo ./iscsi_menu.sh
```

---

## Menu Structure

### Color Coding System

| Color | Code | Menu Options | Purpose |
|-------|------|--------------|---------|
| **Green** | `\033[1;92m` | 1-4 | Setup and network preparation |
| **Yellow** | `\033[1;93m` | 5-8 | Active connection operations |
| **Magenta** | `\033[1;95m` | 9-12 | Advanced configuration and HA |
| **White** | `\033[1;97m` | 13-16 | Maintenance and cleanup |
| **Cyan** | `\033[1;96m` | 17-20 | Information and exit |

---

## Detailed Feature Reference

### Setup & Network (Options 1-4)

**1) Install iSCSI**
- Updates package repository
- Installs `open-iscsi` package
- Enables and starts `iscsid` service
- Configures auto-start on boot

**2) Configure Firewall**
- Checks for UFW installation
- Installs UFW if missing
- Enables firewall
- Allows TCP port 3260 (iSCSI) inbound and outbound
- Adds descriptive comments for rules

**3) Show Network Info**
- Displays all network interfaces (excluding loopback)
- Shows default route/gateway
- Displays DNS server configuration
- Shows system hostname

**4) Ping Target**
- Tests connectivity to target IP
- Sends 3 ICMP packets
- Reports reachability status

---

### Connection Management (Options 5-8)

**5) Discover**
- Prompts for target IP address
- Runs `iscsiadm` sendtargets discovery
- Lists available IQNs from target

**6) Login**
- Prompts for IQN and target IP
- Establishes iSCSI session
- Creates block device (`/dev/sdX`)

**7) Logout**
- Prompts for IQN and target IP
- Terminates iSCSI session
- Removes block device

**8) Sessions**
- Displays active iSCSI sessions
- Shows connection details and state

---

### Advanced Configuration (Options 9-12)

**9) CHAP Authentication**
- Configures username/password authentication
- Sets discovery and session credentials
- Updates node configuration

**10) Persistence**
- Configures auto-login on boot
- Options: `automatic` or `manual`
- Updates node startup parameter

**11) Rescan Bus**
- Scans all SCSI hosts
- Detects new LUNs without dropping sessions
- Useful for hotplug scenarios

**12) Multipath**
- Installs `multipath-tools`
- Enables multipath configuration
- Starts and enables `multipathd` service
- Provides path redundancy

---

### Maintenance (Options 13-16)

**13) IO Stats**
- Installs `sysstat` if missing
- Runs `iostat` with extended statistics
- Shows device utilization and latency

**14) Safe Unmount**
- Identifies mounted iSCSI devices
- Unmounts all `/dev/sd*` filesystems
- Prevents data corruption

**15) Backup Config**
- Creates timestamped tarball of `/etc/iscsi`
- Saves to `/root/iscsi_cfg_YYYY-MM-DD_HHMM.tar.gz`
- Preserves configuration for recovery

**16) Cleanup Nodes**
- Removes all node entries from configuration
- Requires confirmation prompt
- Useful for stale target removal

---

### Information & Exit (Options 17-20)

**17) Tune Timeouts**
- Configures session replacement timeout
- Adjusts for unstable network conditions
- Updates node parameter

**18) Validate**
- Lists block devices with `lsblk`
- Shows recent kernel messages (`dmesg`)
- Confirms device visibility

**19) Workflow Diagram**
- Displays ASCII workflow visualization
- Shows use case summary table
- Provides quick reference guide

**20) Exit**
- Clean application termination
- Returns to system shell

---

## Workflow Diagram

```
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
```

---

## Use Case Scenarios

### Scenario 1: New iSCSI Storage Setup

```bash
# Step 1: Install iSCSI initiator
Option 1

# Step 2: Configure firewall
Option 2

# Step 3: Verify network configuration
Option 3

# Step 4: Discover targets
Option 4
# Enter target IP: 192.168.1.100

# Step 5: Login to target
Option 6
# Enter IQN: iqn.2001-04.com.example:storage
# Enter Target IP: 192.168.1.100

# Step 6: Validate connection
Option 18

# Step 7: Exit
Option 20
```

---

### Scenario 2: CHAP Authentication Setup

```bash
# Step 1: Discover target
Option 4

# Step 2: Configure CHAP
Option 9
# Enter IQN: iqn.2001-04.com.example:storage
# Enter Username: chapuser
# Enter Password: ********

# Step 3: Login
Option 6

# Step 4: Set persistence
Option 10
# Enter IQN: iqn.2001-04.com.example:storage
# Auto Login: yes
```

---

### Scenario 3: Troubleshooting Connection

```bash
# Step 1: Check network configuration
Option 3

# Step 2: Ping target
Option 4
# Enter target IP: 192.168.1.100

# Step 3: View active sessions
Option 8

# Step 4: Validate devices and logs
Option 18

# Step 5: Rescan bus
Option 11

# Step 6: View IO statistics
Option 13
```

---

### Scenario 4: High Availability Setup

```bash
# Step 1: Install and configure primary path
Options 1-6

# Step 2: Enable multipath
Option 12

# Step 3: Configure persistence
Option 10

# Step 4: Backup configuration
Option 15

# Step 5: Validate multipath
Option 18
# Check for multiple paths in lsblk output
```

---

## Configuration Files

### Primary Configuration Directory

```
/etc/iscsi/
├── iscsid.conf          # Main iSCSI daemon configuration
├── initiatorname.iscsi  # Initiator IQN
├── nodes/               # Target node configurations
│   └── [target-iqn]/
│       └── [target-ip]:3260/
│           └── default.conf
└── send_targets/        # Discovered targets
    └── [target-ip]:3260/
        └── send_targets
```

### Backup Location

```
/root/iscsi_cfg_YYYY-MM-DD_HHMM.tar.gz
```

---

## Technical Specifications

### Ports

| Port | Protocol | Direction | Purpose |
|------|----------|-----------|---------|
| 3260 | TCP | Inbound/Outbound | iSCSI traffic |

### Services

| Service | Description | Default State |
|---------|-------------|---------------|
| `iscsid` | iSCSI daemon | Active after installation |
| `multipathd` | Multipath daemon | Active after Option 12 |
| `ufw` | Firewall | Active after Option 2 |

### Commands Used

```bash
iscsiadm -m discovery      # Target discovery
iscsiadm -m node           # Node management
iscsiadm -m session        # Session listing
lsblk                      # Block device listing
dmesg                      # Kernel messages
ip addr                    # Network configuration
ufw                        # Firewall management
```

---

## Troubleshooting

### Common Issues

**Issue: Discovery fails**
```bash
# Verify network connectivity
Option 4 (Ping Target)

# Check firewall rules
sudo ufw status

# Verify iscsid is running
systemctl status iscsid
```

**Issue: Login fails**
```bash
# Check CHAP credentials
Option 9 (Reconfigure CHAP)

# Verify target IQN
Option 5 (Rediscover)

# Check kernel logs
Option 18 (Validate)
```

**Issue: Device not visible**
```bash
# Rescan SCSI bus
Option 11

# Check multipath status
multipath -ll

# View kernel messages
dmesg | tail -n 20
```

---

## Security Considerations

### CHAP Authentication

Always enable CHAP authentication for production environments:

```bash
# Option 9 configures:
discovery.sendtargets.auth.username
discovery.sendtargets.auth.password
node.session.auth.username
node.session.auth.password
```

### Firewall Rules

The script configures minimal required access:

```bash
# Allows only iSCSI traffic
ufw allow 3260/tcp comment 'iSCSI-In'
ufw allow out 3260/tcp comment 'iSCSI-Out'
```

### Configuration Backup

Regularly backup configuration before changes:

```bash
# Option 15 creates timestamped backup
/root/iscsi_cfg_YYYY-MM-DD_HHMM.tar.gz
```

---

## Contributing

### Reporting Issues

1. Document the issue with steps to reproduce
2. Include system information (Ubuntu version)
3. Provide relevant log output from Option 18
4. Submit via GitHub Issues

### Feature Requests

1. Describe the use case
2. Explain expected behavior
3. Provide examples if applicable

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-27 | Initial release with core features |
| 1.1 | 2026-02-27 | Added banner and network info |
| 1.2 | 2026-02-27 | Integrated 10 advanced features |
| 1.3 | 2026-02-27 | Added workflow diagram |
| 1.4 | 2026-02-27 | Implemented color grouping |
| 1.5 | 2026-02-27 | Restored full workflow diagram |

---

## Support

**Website:** Qvert.net  
**Platform:** Ubuntu 22.04 / 24.04  
**Language:** Bash  
**Dependencies:** open-iscsi, ufw, multipath-tools (optional)

---

## License

MIT License

Copyright (c) 2026 Qvert.net

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

**Last Updated:** February 27, 2026
```
