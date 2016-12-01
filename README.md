This repo can be used to create a new docker image

- APACHE
- PHP
- XDEBUG
- AWS CLI


the repo is linked to docker hub so the new image will be build automatically.

if not
docker build .
docker tag [IMAGEID] [USER]/[DOCKER REPO NAME]:[TAG]
docker pull [USER]/[DOCKER REPO NAME]:[TAG]

