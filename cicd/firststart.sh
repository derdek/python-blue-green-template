echo "CLONING REPOSITY ..."
git clone git@github.com:derdek/python-blue-green-template.git www
echo "ENTERING TO WWW FOLDER ..."
cp .env www/.env
cd www
echo "STARTING CONTAINERS ..."
docker-compose up -d
echo "DONE"
