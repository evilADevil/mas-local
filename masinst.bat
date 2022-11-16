@echo off
REM --------------------------------------------------------
REM Windows Batch script to install MAS Manage on OCP Local
REM with only UDS external
REM --------------------------------------------------------
REM    Make sure you have logged into your local OCP before
REM    staring the script
REM --------------------------------------------------------

REM Install the local path provisioner, from the Rancher distro, slightly modified to work on OCP
oc apply -f local-path-storage-mod.yaml
REM Creates a pod to run the MAS ansible collection
oc apply -f masdevops.yaml
oc project mas-devops

REM Waits for the pod to come to life
:notrunning
for /f "tokens=1,3" %%i in ('oc get pods ^| findstr /c:"mas-devops-app-"') do set POD=%%i&set STATUS=%%j
echo %STATUS%
if "%STATUS%" NEQ "Running" timeout 5 > NUL & goto notrunning

REM Cleanup in case of a second run (idempotent)
oc exec %POD% -- rm -r /opt/app-root/src/masloc
REM Clone the latest collection
oc exec %POD% -- git clone https://github.com/ibm-mas/ansible-devops /opt/app-root/src/masloc/ansible-devops
REM Creates the directory where all the MAS configuration will go
oc exec %POD% -- mkdir /opt/app-root/src/masloc/masconfig
REM Uploads the playbook to install MAS on OCP local (this may eventually become part of the MAS collection)
REM --> IMPORTANT <-- You need to modify this file to include your ER key, License ID and external UDS url and api key
oc cp masocpl.yml %POD%:/opt/app-root/src/masloc/ansible-devops/ibm/mas_devops/playbooks
REM Uploads your MAS license file and UDS certificate
oc cp license.dat %POD%:/opt/app-root/src/masloc
oc cp uds.crt %POD%:/opt/app-root/src/masloc

REM Rebuilds the collection to add the new playbook and installs it
for /f "tokens=6" %%i in ('oc exec %POD% -- bash -c "cd masloc/ansible-devops/ibm/mas_devops && ansible-galaxy collection build --force" ^| findstr /c:"Created collection"') do set COLL=%%i
oc exec %POD% -- bash -c "cd masloc/ansible-devops/ibm/mas_devops && ansible-galaxy collection install %COLL% --force"
REM Run the playbook
oc exec %POD% -- bash -c "cd masloc/ansible-devops/ibm/mas_devops && export MAS_APP_SETTINGS_DEMODATA=True && ansible-playbook ibm.mas_devops.masocpl"