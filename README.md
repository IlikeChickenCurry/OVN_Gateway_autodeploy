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

To perform an upgrade to the latest OVN docker image (this is automatic, it uses the config file created when installing/reinstalling).


## Testing (Under Linux)
```sh
curl -H Content-Type: application/json -X POST -d '{connectorId:C1,task:Send transaction}' http://YOUR.PUBLIC.IP.HERE:8080/tasks
```

Change the connectorID to accord with yours.


## Testing (Under Windows and powershell)
```sh
Invoke-WebRequest 'http://YOUR.PUBLIC.IP.HERE:8080/tasks' -Method Post -Body '{connectorId:C7,task:Send transaction}' -ContentType 'application/json'
```

Change the connectorID to accord with yours.



This script is just a POC, but if it can help you, i'll be happy.

