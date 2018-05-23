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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

${DIR}/cleanup.sh

create_storage "primary-deployment"
if [[ $? -ne 0 ]]
then
    echo_err "Failed to create storage, exiting.."
    exit 1
fi

create_storage "metrics"
if [[ $? -ne 0 ]]
then
    echo_err "Failed to create storage, exiting.."
    exit 1
fi

${CCP_CLI?} create secret generic pgbouncer-secrets \
    --from-literal=pgbouncer-password='password'


${CCP_CLI?} create configmap primary-deployment-pgconf \
  --from-file=postgresql=./configs/postgresql.conf \
  --from-file=pghba=./configs/pg_hba.conf \
  --from-file=setup=./configs/setup.sql \
  --from-file=queries=./configs/queries.yml

${CCP_CLI?} create secret generic pgsql-secrets \
    --from-literal=pg-primary-password='password' \
    --from-literal=pg-password='password' \
    --from-literal=pg-root-password='password'


expenv -f $DIR/primary-deployment.json | ${CCP_CLI?} create -f -
expenv -f $DIR/pgbouncer-primary.json | ${CCP_CLI?} create -f -
expenv -f $DIR/metrics.json | ${CCP_CLI?} create -f -
#expenv -f $DIR/pgbouncer-replica.json | ${CCP_CLI?} create -f -
