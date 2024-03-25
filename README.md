![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/TheChrisTech/Storj-Exporter)

## About

This repository is forked off of [anclrii/Storj-Exporter]((https://github.com/anclrii/Storj-Exporter), which unfortunately has gone quiet. This repository was created to fix bugs and add additional features. All original work is credited to anclrii (Thank you!).

Storj exporter for Prometheus written in python. It pulls information from storj node api for `node`, `satellite` and `payout` metrics.

Also check out [Storj-Exporter-dashboard](https://github.com/anclrii/Storj-Exporter-dashboard) for Grafana to visualise metrics for multiple storj nodes.

<img src="https://raw.githubusercontent.com/TheChrisTech/Storj-Exporter-dashboard/056e09de9f55ed7bdf3f52e10cf48cac190cf290/Storj-Exporter.png" height=1187 width=490 align="right"/> 

## Usage

* Exporter can be installed as a docker container, a systemd service or a standalone script
* Make sure you have `-p 127.0.0.1:14002:14002` in storagenode container docker run command to allow local connections to storj node api
* `storagenode` is the default value for `STORJ_HOST_ADDRESS` environment variable that sets the address of the storage node container used to link exporter to the api
* If you storagenode container has a different name it needs to be set with both `--link=<storagenode-name-here>` and `-e STORJ_HOST_ADDRESS=<storagenode-name-here>` on the docker command

### Installation
#### Docker installation
##### Run latest build from DockerHub (easiest option, assuming `storagenode` is the name of the storagenode container)

    docker run -d --link=storagenode --name=storj-exporter -p 9651:9651 -e STORJ_HOST_ADDRESS=storagenode thechristech/storj-exporter:latest

Docker image supports `linux/386,linux/amd64,linux/arm64,linux/arm/v6,linux/arm/v7,linux/arm/v8` platforms.

##### Run multiple instances of exporter to monitor multiple storagenodes running on the same host

In this example `storagenode1, storagenode2, storagenode3` are the names of storagenode containers runnin on the same host. The docker commands would be:

    docker run -d --link=storagenode1 --name=storj-exporter1 -p 9651:9651 -e STORJ_HOST_ADDRESS=storagenode1 thechristech/storj-exporter:latest
    docker run -d --link=storagenode2 --name=storj-exporter2 -p 9652:9651 -e STORJ_HOST_ADDRESS=storagenode2 thechristech/storj-exporter:latest
    docker run -d --link=storagenode3 --name=storj-exporter3 -p 9653:9651 -e STORJ_HOST_ADDRESS=storagenode3 thechristech/storj-exporter:latest

#### Systemd service installation

##### Create storj-exporter user for service

    useradd --no-create-home --shell /bin/false storj_exporter

##### Install package dependencies

    Dependencies: python3 python3-pip
    pip3 install --no-cache-dir -r /requirements.txt
    
##### Move storj_exporter directory to a desired location

    mv storj_exporter/ /opt/
    chown storj_exporter:storj_exporter /opt/storj_exporter/
   
##### Install systemd service and set to start on boot
    
    cp storj_exporter.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl restart storj_exporter
    systemctl enable storj_exporter

##### Standalone script

    python3 /path/to/storj_exporter/

## Installing full monitoring stack (Prometheus + Grafana + Dashboard)

You can find some installation notes and guides in [dashboard README](https://github.com/thechristech/Storj-Exporter-dashboard#installing-full-monitoring-stack), also see [quick-start guide](https://github.com/thechristech/Storj-Exporter-dashboard/tree/master/quick_start) to set up the whole stack using docker-compose.

## Variables
Following environment variables are available:

| Variable name | Description | Docker default | Standalone default |
| --- | --- | --- | --- |
| STORJ_HOST_ADDRESS | Address of the storage node | storagenode | 127.0.0.1 |
| STORJ_API_PORT | Storage node api port | 14002 | 14002 |
| STORJ_API_TIMEOUT | Storage node api timeout | 90 | 90 |
| STORJ_EXPORTER_ADDRESS | Address to expose metrics on - useful for reverse proxy | 127.0.0.1 | 127.0.0.1 |
| STORJ_EXPORTER_PORT | A port that exporter opens to expose metrics on | 9651 | 9651 |
| STORJ_COLLECTORS | A list of collectors | payout sat | payout sat |

### Collectors
By default exporter collects node, payout and satellite data from api. Satellite data is particularly expensive on cpu resources and disabling it might be useful on smaller systems

### Netdata
For users that use Netdata:
Netdata by default has a prometheus plugin enabled, which pulls all the data from the exporter every 5 seconds. This results in high CPU spikes on the storagenode. It is therefore advisable to disable the prometheus plugin of Netdata:
```
cd /etc/netdata
sudo ./edit-config go.d.conf
```
Then under "modules:" uncomment "prometheus" and change its value to "no":
```
modules:
#  activemq: yes
[...]
#  powerdns_recursor: yes
  prometheus: no
```
After that restart the netdata service:
```
sudo systemctl restart netdata
```
