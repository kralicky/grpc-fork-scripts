#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <new module name>"
  exit 1
fi

mod_name="$(go list -m)"
new_mod_name="$1"

for d in $(find . -type d -name "internal"); do
  new_dir=$(dirname "$d")/pkg
  mv "$d" "$new_dir"
  git add "$new_dir"
done

for f in $(find . -type f | grep -vP '^\.\/\.'); do
  sed -i "s|${mod_name}/\(.*\)internal/\(.*\)|${mod_name}/\1pkg/\2|g" "$f"
done

go mod edit -module "$new_mod_name"

for f in $(find . -type f | grep -vP '^\.\/\.'); do
  sed -i "s|${mod_name}|${new_mod_name}|g" "$f"
done

go mod tidy
git add -u
