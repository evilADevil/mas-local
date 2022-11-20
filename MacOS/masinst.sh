#！ /bin/bash

echo "####Pre-install Check####"
## Check if the crc configure can meet the install
telemetryflag=$(crc config view | grep -i 'telemetry' |awk -F ':' '{print $2}')
cpunum=$(crc config view | grep -i 'cpus' |awk -F ':' '{print $2}')
disksize=$(crc config view | grep -i 'disk-size ' |awk -F ':' '{print $2}')
memorysize=$(crc config view | grep -i 'memeory ' |awk -F ':' '{print $2}')
## Start to set up CRC to use the pre-configured
if [[ "$telemetryflag" == "no" ]] && (( $cpunum >= 14 )) && (( $disksize >= 200 )) && (( $memorysize >= 30720 ))
then
  echo "CRC confguration meets the MAS install requirement"
else
  echo "CRC confguration does not meet the MAS install requirement"
  echo "Please double check and run the below command to achieve the minimum configuration and re-run the install script"
  echo "crc config set consent-telemetry no"
  echo "crc config set cpus 14"
  echo "crc config set memory 30720"
  echo "crc start"
  echo "crc stop"
  echo "crc config set disk-size 200"
  echo "crc start"
  exit 1
fi

function checkcrcstatus () {
crcstatus=$1
retry=20
while  ( [ $retry -gt 0 ] )
do
    str1=$( crc status | grep 'CRC' |  grep  'VM' | grep -i "$crcstatus")
    if [[ -n ${str1} ]]; 
    then
      echo "CRC is $crcstatus"
      break
    fi
    sleep 30;
    echo "CRC is not in $crcstatus will check again in 30 sec."
    retry=`expr $retry - 1`
done
if [ $retry -eq 0 ]
then
  echo " CRC fail to $crcstatus correctly in 10 Mins!!! "
  echo " Please Check what's wrong. "
  exit 1
else
  echo "CRC is already in $crcstatus"
fi
}

echo "#1 Check  if crc is install correctly"
## Not check the Openshift status because sometimes CRC cluster still work even the openshift status not running
crcvm= $(crc status | grep 'CRC' |  grep  'VM' | grep 'Running')
if [[ -n  "$crcvm"]]
then
  echo "CRC VM is running now"
else
  echo "CRC VM is not running, pls make sure your CRC is running for MAS install"
  exit 1
fi

## Will add oc check 
echo "=========Check and install oc client======="
oc help
if [[ $? -ne 0 ]]
then
  echo "========You don't have oc client and Prepare Openshift client ==========="
  curl -O "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.10.0/openshift-client-mac-4.10.0.tar.gz"
  tar -xzvf openshift-client-mac-4.10.0.tar.gz
  echo "Need you to run the below command to copy the oc to /usr/local/bin in your macOS and allow it in system prefernece"
  echo "sudo mv oc /usr/local/bin/oc && sudo mv kubectl /usr/local/bin/kubectl"
  exit 1
fi
echo "Now Login the CRC"
logincmd=$(crc console  --credentials | grep -i kubeadmin |grep -i 'To login as an admin, run' |sed  's%To login as an admin, run %%g'| sed "s%'%%g")
eval $logincmd | grep -i 'Login successful.'
if [[ $? == 0 ]]
then 
  echo "Login successful."
else
  echo "Not able to login, please check the CRC status again"
fi

### Now configure the local-path Storage Provisoner
oc apply -f local-path-storage-mod.yaml

## Creates a pod to run the MAS ansible collection
oc apply -f masdevops.yaml
oc project mas-devops
POD=$(oc get pods | grep -i mas-devops-app | awk '{print $1}')
## Wait for 3 mins for Pod to start up.
retry=20
while  ( [ $retry -gt 0 ] )
do
    str1=$( oc get pods -n mas-devops | grep -i mas-devops-app | grep -i 'running')
    if [[ -n ${str1} ]]; 
    then
      echo "Pod is running"
      break
    fi
    sleep 30;
    echo "Pod is not running, will check again in 30 sec."
    retry=`expr $retry - 1`
done
if [ $retry -eq 0 ]
then
  echo " Pod fail to run correctly in 10 Mins!!! "
  echo " Please Check what's wrong and re-run the install script "
  exit 1
else
  echo "Pod is Running Well"
fi

### Prepare ro run the ansible playbook in the pods
oc exec $POD -- rm -rf /opt/app-root/devops/playbooks
oc exec $POD -- rm -rf /opt/app-root/devops/roles

###Clone the latest collection
oc exec $POD -- git clone https://github.com/ibm-mas/ansible-devops /tmp/ansible-devops
oc exec $POD -- cp -rf /tmp/ansible-devops/ibm/mas_devops/playbooks /opt/app-root/devops/
oc exec $POD -- cp -rf /tmp/ansible-devops/ibm/mas_devops/roles /opt/app-root/devops/

##Creates the directory where all the MAS configuration will go
masconfgpath="/tmp/masconfig"
oc exec $POD -- mkdir $masconfgpath

## Uploads your MAS license file and UDS certificate
oc cp license.dat mas-devops/$POD:$masconfgpath/license.dat
oc cp uds.crt mas-devops/$POD:$masconfgpath/uds.crt
###copy the ansible install script to pod 
oc cp install.sh mas-devops/$POD:/tmp/install.sh
### Run the playbook
oc exec $POD -- bash -c "cd /tmp && nohup ./install.sh  > oneclick_manage.log 2>&1 &"
oc exec $POD -- tail -f /tmp/oneclick_manage.log
