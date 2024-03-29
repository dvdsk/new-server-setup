# Home server setup:

Personal home server setup hosting:
- haproxy for tls and forwarding
- matrix homeserver
	- telegram matrix bridge
	- discord matrix bridge
<!-- - private site -->
- home automation backend
- home data backend
	- data splitter
	- data server 
	- data server dev

## Forwarding and TLS
HAproxy is used to
- forwarding https traffic to backends based on url
- handle tls termination (port 443 and matrix)

HAproxy is started by systemd as root, binds to privelledged ports and then runs as that user *haproxy*. I use systemd to sandbox HAproxy as much as possible. I use certbot to request and renew the certificate. Certbot is ran twice a day using systemd timers.

### note on dns
A catch all subdomain should be added to the DNS records. Currently I use subdomains: ha, data and devk_data. Instructions (here)[https://www.namecheap.com/support/knowledgebase/article.aspx/597/2237/how-can-i-set-up-a-catchall-wildcard-subdomain/]. This also works with dynamic dns.

### local ports
Ports should be assigned between 1024 and 49151. I use 34320-34335. These need to match the backends in config/haproxy.cfg.
 - certbot (renew\_certs) 34320
 - matrix (TODO) 34321
	 - reserved for telegram bridge 34322
	 - reserved for discord bridge 34323
	 - reserved for future bridge 34324
	 - reserved for future bridge 34325
 - home automation (ha) 34326
 - data splitter (datasplitter) 34327
 - data server (data) 34328
 - data server dev (data\_dev) 34329
 - web server (webserver) 34330

### install
Simply clone this repo and run setup/haproxy.sh

## Matrix

### install

#### telegram bridge
run setup/matrix\_bridges/telegram.sh. Now create a new unencrypted room in matrix and invite the telegram bot. If everything works it will instruct you on how to login.


## Home Automation
From sensordata, button presses, wakeup time, playing audio and telegram bot input: manages wakeup "alarm", lamps and music. [source](https://github.com/dskleingeld/HomeAutomation).

Recieves: 
on domain.tld:433/ha\_key: TODO change to 127.0.0.1/ha\_key or ha.domain.tld/ha\_key
- sensordata (including button pushes) from microservice [sensor central](https://github.com/dskleingeld/sensor_central) 
on domain.tld:433/bot\_token: TODO change to ha.domain.tld/bot\_token
- telegram bot messages via webhook 
on domain.tld:433/alarm/..: TODO change to ha.domain.tld/wakeup/..
- wakeup time from [alarm app](https://github.com/dskleingeld/alarm)
on domain.tld:433/commands/..  TODO change to ha.domain.tld/api/..
- http api to perform an action or change state

### install 
Run setup/ha.sh
make sure to set up home sensors

## Home Data Collection
Collects and inspect data from various sensors. Provides notifications at threshold values, interface using telegram bot and site. [source](https://github.com/dskleingeld/dataserver)

Recieves: TODO change all these to data.domain.tld/..
on domain.tld:88/post\_..: TODO on on local 127.0.0.1/post\_
- sensor data from microservice [sensor central](https://github.com/dskleingeld/sensor_central) 
- sensor data from remote wifi sensor
on domain.tld:88/..:
- site, websocket data, static files
on domain.tld:88/bot\_token:
- telegram bot

I also run a development version of this on dev.data.domain.tld/.. incoming data is split between both instances using [data splitter](https://github.com/dskleingeld/datasplitter). It recieves domain.tld:88/post\_.. and forwards it to both instances.

### install 
Run setup/data.sh

## Home sensors
Measures using attached sensors and collects data from ble sensors in the field. Sends data to the data collection instances and to the home automation system.

### install 
Run setup/sens.sh
