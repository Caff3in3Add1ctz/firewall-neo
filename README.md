# firewall-neo
All-In-One firewall management system. Currently tested on Fedora/RHEL9/Debian 13/Ubuntu Server 24.04 LTS. In the process of testing other distros. In theory, it should work under other distros that utilize bash as the shell.
To Run It:
  1. System-Wide (Any User with Sudo access):
  
    a. Copy the three scripts to /usr/local/bin:
         sudo cp firewall-neo.sh firewall-neo-create.sh firewall-neo-delete.sh /usr/local/bin/
  
    b. Set owner and permissions:
         sudo chown root:wheel /usr/local/bin/firewall-neo*.sh
         sudo chmod 750 /usr/local/bin/firewall-neo*.sh
  
    c. Check your user is in the wheel group:
         id <user>
  
    d. If wheel is missing, add it, then log out and back in:
         sudo usermod -aG wheel <user>
  
    e. Run the script from anywhere:
         sudo firewall-neo.sh
  
    f. (Optional) You can set a symbolic link to run it when you type "firewall":
         ln -s /usr/local/bin/firewall-neo.sh /usr/local/bin/firewall
  
  2. Local user Mode (requires absolute path-name to run, without sym. links)

    a. "Fill in later."
