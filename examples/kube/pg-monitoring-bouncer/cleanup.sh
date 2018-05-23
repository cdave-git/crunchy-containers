#!/bin/bash
# Copyright 2017 - 2018 Crunchy Data Solutions, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source ${CCPROOT}/examples/common.sh
echo_info "Cleaning up.."

${CCP_CLI?} delete deploy primary-deployment replica-deployment replica2-deployment
${CCP_CLI?} delete configmap primary-deployment-pgconf
${CCP_CLI?} delete secret pguser-secret pgprimary-secret pgroot-secret
${CCP_CLI?} delete secret pgbouncer-secrets
${CCP_CLI?} delete secret pgsql-secrets

sleep 10

${CCP_CLI?} delete service primary-deployment
${CCP_CLI?} delete service replica-deployment
${CCP_CLI?} delete service pgbouncer-primary pgbouncer-replica

${CCP_CLI?} delete pvc primary-deployment-pgwal primary-deployment-pgbackrest primary-deployment-pgdata
${CCP_CLI?} delete pvc replica-deployment-pgwal replica-deployment-pgbackrest replica-deployment-pgdata
${CCP_CLI?} delete pvc replica2-deployment-pgwal replica2-deployment-pgbackrest replica2-deployment-pgdata

${CCP_CLI?} delete pod pgbouncer-primary pgbouncer-replica

if [ -z "$CCP_STORAGE_CLASS" ]; then
  ${CCP_CLI?} delete pv primary-deployment-pgwal primary-deployment-pgbackrest primary-deployment-pgdata
  ${CCP_CLI?} delete pv replica-deployment-pgwal replica-deployment-pgbackrest replica-deployment-pgdata
  ${CCP_CLI?} delete pv replica2-deployment-pgwal replica2-deployment-pgbackrest replica2-deployment-pgdata
fi

$CCPROOT/examples/waitforterm.sh pgbouncer-primary ${CCP_CLI?}
$CCPROOT/examples/waitforterm.sh pgbouncer-replica ${CCP_CLI?}
$CCPROOT/examples/waitforterm.sh primary-deployment ${CCP_CLI?}



${CCP_CLI?} delete clusterrolebinding prometheus-sa
${CCP_CLI?} delete clusterrole prometheus-sa
${CCP_CLI?} delete sa prometheus-sa
${CCP_CLI?} delete pod metrics
${CCP_CLI?} delete service metrics

${CCP_CLI?} delete pvc metrics-prometheusdata
${CCP_CLI?} delete pvc metrics-grafanadata
if [ -z "$CCP_STORAGE_CLASS" ]; then
  ${CCP_CLI?} delete pv metrics-prometheusdata metrics-grafanadata
fi

$CCPROOT/examples/waitforterm.sh metrics ${CCP_CLI?}

