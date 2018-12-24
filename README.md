This repo can be used to create a new docker image

- APACHE
- PHP
- XDEBUG
- XHPROF (vhost URL: xhprof.local - tmp folder /tmp/xhprof  -  xhprof_lib directory '/usr/share/php')
- AWS CLI


the repo is linked to docker hub so the new image will be build automatically.

if not:

- docker build .
- docker tag [IMAGEID] [USER]/[DOCKER REPO NAME]:[TAG]
- docker push [USER]/[DOCKER REPO NAME]:[TAG]

docker hub link:
https://hub.docker.com/r/flevanti/docker_webserver/builds/
