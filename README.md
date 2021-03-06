## Requirements
- Docker
- Your Public IP
- Your BPI Key

You can execute the script with 3 different arguments :

## Install
```sh
./OVN_gateway.sh install
```

To perform the initial installation of the OVN Gateway (you will need your public IP and BPI Key).

## Reinstall
```sh
./OVN_gateway.sh reinstall
```

To perform a reinstallation of the OVN Gateway (you will need your public IP and BPI Key).

## Upgrade
```sh
./OVN_gateway.sh upgrade
```

To perform an upgrade to the latest OVN docker image (this is automatic, it uses the config file created when installing/reinstalling, it contains your IP and BPIKEY).


## Testing (Linux CLI)
```sh
curl -H "Content-Type: application/json" -X POST -d '{"connectorId":"C1","task":"Send transaction"}' http://YOUR.PUBLIC.IP.HERE:8080/tasks
```

Change the IP address and connectorID to accord with yours.


## Testing (Windows Powershell)
```sh
Invoke-WebRequest 'http://YOUR.PUBLIC.IP.HERE:8080/tasks' -Method Post -Body '{"connectorId":"C7","task":"Send transaction"}' -ContentType 'application/json'
```

Change the IP address and connectorID to accord with yours.


## NOTE
This script is just a POC(KISS mode), but if it can help you, i'll be happy, it's intended to work on a dedicated server for the OVN Gateway, with only one instance of the OVN Gateway and one instance of mongoDB (It uses the containers name instead of IDs, but if needed, that behavior can be changed easily)

