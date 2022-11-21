# Install MAS in MacOS laptop

## 1. Install Openshift local to your laptop
Open [Red Hat Console for OpenShift](https://console.redhat.com/openshift) and folllow the Steps to install CRC 
- click on the *Create Cluster* button
- click on the *Local* tab, download and install OpenShift Local (also know previously as CRC, i.e. Code Ready Container). 
- Install the CRC by clicking the downloaded packages
- After CRC is installed , run the below command to prepare the crc configuration and start it for MAS Manage install
```bash
crc config set consent-telemetry no
crc config set cpus 14
crc config set memory 30720
crc start
crc stop
crc config set disk-size 200
crc start
```

!!!note:  In that same page, there is your pull secret that you'll need to copy and use during setup

  
## 2. Install openshift client command line 

You need to download and install openshift client command line following the below steps:

- Run the below command to install oc to MacOS laptop
```Bash
  curl -O "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.10.0/openshift-client-mac-4.10.0.tar.gz"
  tar -xzvf openshift-client-mac-4.10.0.tar.gz
  chmod +x oc kubectl
  sudo mv oc /usr/local/bin/oc && sudo 
  sudo mv kubectl /usr/local/bin/kubectl 
  oc --help
```
- Go to  `System preferences` and `Security & Privacy` to Allow its execution permission.
  
## 3. Configure the necessary file and Env var in the install.sh    

Download the automation install script to your laptop
```bash
git clone mas-local
cd mas-local/MacOS
```

### 3.1 Prepare your `license.dat` for MAS install and put it under this folder


### 3.2 Prepare UDS related Env var and also prepare the `uds.crt` file and save it to current folder.
As UDS is only one time connection for MAS install, you can use the existing UDS server and no need to install it in CRC. You need to know 

**UDS_ENDPOINT_URL** : `url of the remote UDS server.`
**UDS_API_KEY** : `api key of the remote UDS server`

After you get the above 2 Env info from the existing UDS server, just export the Env Vars in `install.sh` file.

`uds.crt` You need retrieve it and generate the file.
 You can get it by run `openssl s_client`, e.g if your `UDS_ENDPOINT_URL="https://uds-endpoint-ibm-common-services.masms-xxx.us-south.containers.appdomain.cloud"`, you can run below command 
```
openssl s_client -servername uds-endpoint-ibm-common-services.masms-xxx.us-south.containers.appdomain.cloud -connect uds-endpoint-ibm-common-services.masms-xxx.us-south.containers.appdomain.cloud:443  -showcerts
```
Then combined all certificates parts between
-----BEGIN CERTIFICATE-----
xxxxxxxx
-----END CERTIFICATE-----
to generate the `uds.crt` file like this and put the file here.
```yaml
-----BEGIN CERTIFICATE-----
xxxxxxxx
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
xxxxxxxx
-----END CERTIFICATE-----
```

### 3.3 Replace and export the other Env vars with the yours in  `install.sh` script.
```bash
### Pls replace the entitlemwnt key with yours

export IBM_ENTITLEMENT_KEY=eyJhbGciOiJIUzI1NiJ9xxxx
```

**Entitled Registry (ER) key** : This key will have to be enabled to get the MAS and CloudPak for Data images and You can get it by logging into [My IBM](https://myibm.ibm.com/dashboard/) and click on *Container Software & Entitlement key*

```
### SLS License key info you need to change 
export SLS_LICENSE_ID=xxxx
```
**SLS_LICENSE_ID** matching the MAS license file. You can find out what this is by open the license file in an editor, and check the first line. The license id will be the second-last number. For example, if your first line is `SERVER sls-rlks-0.rlks 0272bc344002 27000` then your icense id is `0272bc344002`.

## 4. Run masinst.sh to kick off the MAS install

```
./masinst.sh
``` 
As the log proceed, pay attention to record the userid and password of the MAS superuser, that should look like this:
```
ok: [localhost] => {
    "msg": [
        "Maximo Application Suite is Ready, use the superuser credentials to authenticate",
        "Admin Dashboard ... https://admin.masdemo.apps-crc.testing",
        "Username .......... DIZv7X2eavITxb3vKtf3XRsY85UYj7FV",
        "Password .......... 58Wi9n9U4yVgZ7AhXVRS4eIqEQSnMhsq"
    ]
}
```
In case you don't have the log anymore, you can always retrieve them from the `masdemo-credentials-superuser` secret in the `mas-masdemo-core` namespace.