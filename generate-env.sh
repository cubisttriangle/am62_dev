#!/bin/bash

ENV_FILE=".env"

echo "USER=${USER}" > ${ENV_FILE}
echo "GROUP=${GROUP:=$USER}" >> ${ENV_FILE}
echo "USER_ID=${USER_ID:=$(id -u $USER)}" >> ${ENV_FILE}
echo "GROUP_ID=${GROUP_ID:=$(id -g $USER)}" >> ${ENV_FILE}
