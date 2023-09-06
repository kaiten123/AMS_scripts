#!/bin/bash

curl -u admin:"$(pass CQ_Admin)" -X GET http://localhost:4502/etc/reports/diskusage.html?path=/var/commerce/products