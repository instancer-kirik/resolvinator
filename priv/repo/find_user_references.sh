#!/bin/bash

echo "Searching for migrations with references to users table..."
grep -r "references(:users" /home/kirik/_Code/Elixir/veix/apps/resolvinator/priv/repo/migrations/
