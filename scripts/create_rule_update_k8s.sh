#!/bin/bash

base_dir=$(dirname "$(readlink -f "$0")")
search_dir="${base_dir}/../customized"
temp_dir="${base_dir}/../tmp"

nrules=0
if [ "$(ls -A $search_dir)" ]; then
  rules_files=
  for entry in "$search_dir"/*
  do
    rules_files="$rules_files $entry"
    nrules=$((nrules+1))
  done
  "$base_dir/rules2helm.sh" $rules_files > "$temp_dir/rule_update_falco.yaml"
fi
echo "$nrules custom rule files for update"



