# Reduce Memory Cache Script for Linux


# Overview
The reduce_memory.sh script is designed to automatically clear the system's memory cache on Linux operating systems. This can be particularly useful for servers or systems that remain operational for extended periods and might benefit from periodic cache clearance to free up unused memory.

This repository contains three key components:

reduce_memory.sh: The Bash script that clears the memory cache when executed.
reduce_memory.service: A systemd service file that defines how the script should be executed.
reduce_memory.timer: A systemd timer file that schedules the periodic execution of the script.


# Installation
The installation process is streamlined with the install.sh script. This script automatically places the reduce_memory.sh, reduce_memory.service, and reduce_memory.timer files in their appropriate locations and enables the timer to ensure the script is executed every 10 minutes, as well as at system startup.
```
git clone https://github.com/byfranke/reducememory
```

# Usage
Download the Scripts: Clone this repository or download the .sh and .service files to your local system.

Make install.sh Executable: Change the permission of the install.sh script to make it executable by running:
```
chmod +x install.sh
```

Run install.sh as Root: Execute the install.sh script with root privileges to automatically install and configure the service. In the terminal, execute:
```
sudo ./install.sh
```

After installation, the reduce_memory.sh script will run in the background every 10 minutes to clear the memory cache, without requiring any further action.

# Note
Running this script might be beneficial for specific use cases where freeing up cache memory is necessary. However, please note that the Linux kernel manages memory efficiently, including cache memory usage. Clearing the cache frequently may impact performance for some applications. Use this script judiciously, considering your system's specific needs and behavior.
