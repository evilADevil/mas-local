### Pls replace the entitlemwnt key with yous
export IBM_ENTITLEMENT_KEY=eyJhbGciOiJIUzI1NiJ9xxxx

### No need to change the Channel if you plan to install 8.8.x
export MAS_CHANNEL=8.8.x
export MAS_APP_CHANNEL=8.4.x

###No need to change if you plan to use the folder path
export MAS_INSTANCE_ID=masdemo
export MAS_CONFIG_DIR=/tmp/masconfig
export MAS_WORKSPACE_ID=main

### SLS License key info you need to change 
export SLS_LICENSE_ID=xxxx
export SLS_LICENSE_FILE="${MAS_CONFIG_DIR}/license.dat"

### UDS info you want to connect during MAS install
#### Need to replace the below 3 items
export UDS_ENDPOINT_URL=xxxx
export UDS_TLS_CERT_LOCAL_FILE_PATH="${MAS_CONFIG_DIR}/uds.crt"
export UDS_API_KEY=xxx
#### No need to change below if you won't
export UDS_CONTACT_EMAIL=nobody@abc.com
export UDS_CONTACT_FIRSTNAME=nobody
export UDS_CONTACT_LASTNAME=nobody

export UDS_STORAGE_CLASS=local-path


### Mongo Storage class and size
export MONGODB_STORAGE_CLASS=local-path
export MONGODB_CPU_REQUESTS=50m
export MONGODB_MEM_REQUESTS=256Mi

### No need to change the below session if you install manage 8.8.x

export MAS_ENTITLEMENT_KEY=${IBM_ENTITLEMENT_KEY}
export MAS_APP_ID=manage

###Confgur the DB2 Disk Size and No need to change 
export DB2_META_STORAGE_CLASS="local-path"
export DB2_META_STORAGE_SIZE="10Gi"
export DB2_DATA_STORAGE_CLASS="local-path"
export DB2_DATA_STORAGE_SIZE="10Gi"
export DB2_BACKUP_STORAGE_CLASS="local-path"
export DB2_BACKUP_STORAGE_SIZE="10Gi"
export DB2_LOGS_STORAGE_CLASS="local-path"
export DB2_LOGS_STORAGE_SIZE="10Gi"
export DB2_TEMP_STORAGE_CLASS="local-path"
export DB2_TEMP_STORAGE_SIZE="10Gi"
export DB2_META_STORAGE_ACCESSMODE=ReadWriteOnce
export DB2_BACKUP_STORAGE_ACCESSMODE=ReadWriteOnce 
export DB2_DATA_STORAGE_ACCESSMODE=ReadWriteOnce
export DB2_BACKUP_STORAGE_ACCESSMODE=ReadWriteOnce
export DB2_LOGS_STORAGE_ACCESSMODE=ReadWriteOnce
export DB2_TEMP_STORAGE_ACCESSMODE=ReadWriteOnce
export DB2_CPU_REQUESTS=500m
export DB2_MEMORY_REQUESTS=3Gi

###Confgure if we need to install AIO and sample data, no need to change
export MAS_APP_SETTINGS_AIO_FLAG=false
export MAS_APP_SETTINGS_DEMODATA=true

###comment out the role not required
sed -i 's%- ibm.mas_devops.sbo%#- ibm.mas_devops.sbo%g' /opt/app-root/devops/playbooks/oneclick_core.yml
sed -i 's%- ibm.mas_devops.cluster_monitoring%#- ibm.mas_devops.cluster_monitoring%g' /opt/app-root/devops/playbooks/oneclick_core.yml
sed -i 's%- ibm.mas_devops.suite_dns%##- ibm.mas_devops.suite_dns%g' /opt/app-root/devops/playbooks/oneclick_core.yml

ansible-playbook /opt/app-root/devops/playbooks/oneclick_core.yml
ansible-playbook /opt/app-root/devops/playbooks/oneclick_add_manage.yml
