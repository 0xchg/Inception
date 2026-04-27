#!/bin/bash

set -e

mkdir -p /run/php

exec php-fpm8.2 --nodaemonize
