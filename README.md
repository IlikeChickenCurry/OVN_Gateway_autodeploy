##Requirements
- Docker
- Your Public IP
- Your BPI Key

You can execute the script with 3 different arguments :

```sh
./OVN_gateway.sh install
```

To perform the initial installation of the OVN Gateway (you will need your public IP and BPI Key).


```sh
./OVN_gateway.sh reinstall
```

To perform a reinstallation of the OVN Gateway (you will need your public IP and BPI Key).


```sh
./OVN_gateway.sh upgrade
```

To perform an upgrade to the latest OVN docker image (this is automatic, it uses the config file created when installing/reinstalling).



This script is just a POC, but if it can help you, i'll be happy.
