## Install the local provisioning storage class
## oc apply -f local-path-storage-mod.yaml

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

## Cleanup in case of a second run
oc exec $POD -- rm -rf /opt/app-root/src/masloc
## Clone the latest collection
oc exec $POD -- git clone https://github.com/ibm-mas/ansible-devops /opt/app-root/src/masloc/ansible-devops
## Creates the directory where all the MAS configuration will go
oc exec $POD -- mkdir /opt/app-root/src/masloc/masconfig
# Upload the playbook to install MAS on OCP
oc cp masocpl.yml $POD:/opt/app-root/src/masloc/ansible-devops/ibm/mas_devops/playbooks
## Uploads your MAS license file
oc cp license.dat mas-devops/$POD:/opt/app-root/src/masloc
IFS=' '
read -a strarr <<< $(oc exec $POD -- bash -c "cd /opt/app-root/src/masloc/ansible-devops/ibm/mas_devops && ansible-galaxy collection build --force" | grep -i 'Created collection')
oc exec $POD -- bash -c "cd /opt/app-root/src/masloc/ansible-devops/ibm/mas_devops && ansible-galaxy collection install ${strarr[5]} --force"
## Run the playbook
oc exec $POD -- bash -c "cd /opt/app-root/src/masloc/ansible-devops/ibm/mas_devops && export MAS_APP_SETTINGS_DEMODATA=True && ansible-playbook ibm.mas_devops.masocpl"
