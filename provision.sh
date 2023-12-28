#!/bin/bash
cd ~
curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh

sudo apt-get update -y
sudo apt upgrade -y
sudo apt install nodejs -y
sudo apt install npm -y
sudo apt install build-essential -y

cd ~
sudo npm init -y
sudo npm install express -y

tee hello.js<<EOF
const express = require('express')
const app = express()
const port = 3000

app.use(express.static('public'));

app.get('/', (req, res) => {
   res.sendFile(__dirname + '/public/index.html');
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
}) 
EOF

sudo npm install pm2@latest -g
sudo pm2 start hello.js -n api-service-staging
sudo pm2 save
sudo pm2 startup systemd


sudo apt install -y nginx
sudo systemctl enable nginx
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

tee example.com<<EOF
server {
     listen [::]:80;
     listen 80;

     server_name example.com www.example.com;

     location / {
         proxy_pass http://localhost:3000;
         proxy_http_version 1.1;
         proxy_set_header Upgrade \$http_upgrade;
         proxy_set_header Connection 'upgrade';
         proxy_set_header Host \$host;
         proxy_cache_bypass \$http_upgrade;
    }
}
EOF

sudo cp example.com /etc/nginx/sites-available/example.com
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/example.com
sudo nginx -t
sudo service nginx restart
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 3000
sudo ufw enable