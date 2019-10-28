#!/bin/bash
#
# These instructions are used when starting the docker container with `docker-compose up`.
# For further configuration details, have a look at the `docker-compose.yml` file.
#
cd /code
source .secrets.sh
./install.sh