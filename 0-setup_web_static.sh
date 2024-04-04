#!/usr/bin/env bash
# Install Nginx if it's not already installed
if ! command -v nginx &> /dev/null; then
    sudo apt update
    sudo apt install nginx -y
fi

# Create necessary directories if they don't exist
sudo mkdir -p /data/web_static/releases/test /data/web_static/shared /data/web_static/current

# Create a fake HTML file for testing
echo "<html><body>Test Page</body></html>" | sudo tee /data/web_static/releases/test/index.html > /dev/null

# Create or update the symbolic link
sudo ln -sf /data/web_static/releases/test/ /data/web_static/current

# Give ownership of the /data/ folder to the ubuntu user and group
sudo chown -R ubuntu:ubuntu /data/

# Update Nginx configuration to serve the content of /data/web_static/current/
# Use alias inside the Nginx configuration
nginx_config="/etc/nginx/sites-available/default"
nginx_config_backup="/etc/nginx/sites-available/default.backup"

# Backup the original configuration file
sudo cp $nginx_config $nginx_config_backup

# Update the configuration file
sudo sed -i 's#^\s*location / {#location / {\n\t\talias /data/web_static/current/;\n\t\t# Serve static content directly\n\t\tlocation /hbnb_static/ {\n\t\t\talias /data/web_static/current/;\n\t\t}\n#' $nginx_config

# Restart Nginx
sudo systemctl restart nginx
