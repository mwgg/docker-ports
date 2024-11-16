# docker-ports.sh
A simple Bash script that generates a formatted, ordered list of port bindings across your Docker containers. This is useful for identifying which ports are already in use when setting up new containers or services.

### Example output
```
Host     Container    Protocol    Host         Container Name               Compose Project
53       53           TCP         0.0.0.0      dns-server                   technitium
53       53           UDP         0.0.0.0      dns-server                   technitium
80       80           TCP         0.0.0.0      nginx-proxy-manager          nginx-proxy-manager
81       81           TCP         0.0.0.0      nginx-proxy-manager          nginx-proxy-manager
443      443          TCP         0.0.0.0      nginx-proxy-manager          nginx-proxy-manager
1096     80           TCP         0.0.0.0      freshrss                     freshrss
3000     3000         TCP         127.0.0.1    homepage                     homepage
3001     3001         TCP         0.0.0.0      uptime_kuma                  uptime_kuma
32769    80           TCP         0.0.0.0      blissful_gould               N/A
```

### Basic usage
1. Clone the repository or copy the contents of docker-ports.sh to the Linux machine running your Docker containers.
2. Make the script executable: chmod +x docker-ports.sh.
3. Run the script: ./docker-ports.sh or /path/to/docker-ports.sh.


Contributions, ideas, and suggestions are welcome.