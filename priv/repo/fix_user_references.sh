#!/bin/bash

# Function to fix a migration file
fix_migration() {
  local file="$1"
  echo "Fixing $file..."
  
  # Create a temporary file
  temp_file=$(mktemp)
  
  # Process the file
  awk '
    {
      # Replace references(:users with :binary_id and add comment
      if ($0 ~ /references\(:users/) {
        # Extract the column name
        match($0, /add :([^,]+),/, col)
        column_name = substr($0, RSTART+5, RLENGTH-6)
        
        # Extract any constraints like null: false
        has_constraints = ($0 ~ /null: (true|false)/)
        if (has_constraints) {
          match($0, /null: (true|false)/, constraints)
          constraint = substr($0, RSTART, RLENGTH)
        } else {
          constraint = ""
        }
        
        # Print the comment explaining why we removed the foreign key
        print "      # Note: " column_name " references resolvinator_acts_fdw.users but we cannot use a foreign key"
        print "      # constraint because PostgreSQL does not support foreign keys to foreign tables."
        print "      # Referential integrity will be handled at the application level."
        
        # Print the modified line
        if (constraint != "") {
          print "      add :" column_name ", :binary_id, " constraint
        } else {
          print "      add :" column_name ", :binary_id"
        }
        next
      }
      
      # Fix any invalid add statements with missing column names
      if ($0 ~ /add :, :binary_id/) {
        # Extract the column name from the comment above
        getline prev < FILENAME
        if (prev ~ /Note: ([^ ]+) references/) {
          match(prev, /Note: ([^ ]+) references/, col)
          column_name = substr(prev, RSTART+6, RLENGTH-16)
          
          # Extract any constraints
          has_constraints = ($0 ~ /null: (true|false)/)
          if (has_constraints) {
            match($0, /null: (true|false)/, constraints)
            constraint = substr($0, RSTART, RLENGTH)
          } else {
            constraint = ""
          }
          
          # Print the fixed line
          if (constraint != "") {
            print "      add :" column_name ", :binary_id, " constraint
          } else {
            print "      add :" column_name ", :binary_id"
          }
        } else {
          print "      # ERROR: Could not determine column name"
          print $0
        }
        next
      }
      
      # Handle modify statements
      if ($0 ~ /modify :.*references\(:users/) {
        # Extract the column name
        match($0, /modify :([^,]+),/, col)
        column_name = substr($0, RSTART+8, RLENGTH-9)
        
        # Extract any constraints
        has_constraints = ($0 ~ /null: (true|false)/)
        if (has_constraints) {
          match($0, /null: (true|false)/, constraints)
          constraint = substr($0, RSTART, RLENGTH)
        } else {
          constraint = ""
        }
        
        # Print the comment explaining why we removed the foreign key
        print "      # Note: " column_name " references resolvinator_acts_fdw.users but we cannot use a foreign key"
        print "      # constraint because PostgreSQL does not support foreign keys to foreign tables."
        print "      # Referential integrity will be handled at the application level."
        
        # Print the modified line
        if (constraint != "") {
          print "      modify :" column_name ", :binary_id, " constraint
        } else {
          print "      modify :" column_name ", :binary_id"
        }
        next
      }
      print
    }
  ' "$file" > "$temp_file"
  
  # Replace the original file with the fixed version
  mv "$temp_file" "$file"
}

# Process each migration file
for file in /home/kirik/_Code/Elixir/veix/apps/resolvinator/priv/repo/migrations/*.exs; do
  if grep -q "references(:users\|add :, :binary_id" "$file"; then
    fix_migration "$file"
  fi
done

echo "All migrations have been updated!"
