#!/bin/bash

# Update all references to the old namespace
find . -type f -name "*.ex" -o -name "*.exs" | while read file; do
  # Skip files in _build and deps directories
  if [[ $file != ./_build/* ]] && [[ $file != ./deps/* ]]; then
    sed -i 's/VES\.Accounts/Acts/g' "$file"
    sed -i 's/Resolvinator\.Accounts/Resolvinator.Acts/g' "$file"
    sed -i 's/Veix\.Accounts/Acts/g' "$file"
  fi
done

# Also update directory names
if [ -d "lib/resolvinator/accounts" ]; then
  mv lib/resolvinator/accounts lib/resolvinator/acts
fi
