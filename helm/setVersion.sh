#!/usr/bin/env sh
sed -i "s/\${version}/$1/g" ./helm/Chart.yaml
