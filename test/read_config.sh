#!/bin/bash

i=0
while read line; do
  if [[ "$line" =~ ^[^#]*= ]]; then
    name[i]=${line%%=*}
    value[i]=${line##*=}
    ((i++))
  fi
done < .myconfig

echo "total array elements: ${#name[@]}"
echo "name[0]: '${name[0]}'"
echo "value[0]: '${value[0]}'"
echo "name[1]: '${name[1]}'"
echo "value[1]: '${value[1]}'"
echo "name array: '${name[@]}'"
echo "value array: '${value[@]}'"