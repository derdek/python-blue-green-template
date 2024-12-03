#!/bin/bash

echo "CLONING REPOSITY ..."
git clone git@github.com:derdek/python-blue-green-template.git www
echo "ENTERING TO WWW FOLDER ..."
cp .env www/.env
cd www
echo "Creating dynamic/http.routers.docker-localhost.yml"
bash check_dynamic_main.sh
echo "WRITING LAST_COMMIT_HASH TO .env FILE ..."
bash write_last_commit_hash_to_env.sh
echo "STARTING CONTAINERS ..."
docker-compose up -d
echo "DONE"
