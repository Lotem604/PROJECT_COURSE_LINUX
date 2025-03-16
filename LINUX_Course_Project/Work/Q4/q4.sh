#!/bin/bash

# Check if a CSV file name was passed as the first parameter
CSV_FILE="$1"

# If no CSV file provided, search for a single CSV file in the current directory
if [ -z "$CSV_FILE" ]; then
  echo "No CSV file provided as a parameter. Searching in the current directory..."
  NUM_CSV=$(ls *.csv 2>/dev/null | wc -l)
  
  if [ "$NUM_CSV" -eq 1 ]; then
    CSV_FILE=$(ls *.csv)
    echo "Found one CSV file: $CSV_FILE"
  elif [ "$NUM_CSV" -gt 1 ]; then
    echo "Multiple CSV files found in the current directory. Please specify which one to use."
    exit 1
  else
    echo "No CSV file found in the current directory. Please pass a file as a parameter."
    exit 1
  fi
fi

# Check if the file exists
if [ ! -f "$CSV_FILE" ]; then
  echo "File $CSV_FILE does not exist. Exiting."
  exit 1
fi

# venv
VENV_DIR="venv"
REQ_FILE="../Q2/requirements.txt"

if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment (venv)..."
  python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

if [ -f "$REQ_FILE" ]; then
  echo "Installing packages from $REQ_FILE ..."
  pip install --upgrade pip
  pip install -r "$REQ_FILE"
else
  echo "requirements.txt not found at: $REQ_FILE"
  echo "Please ensure the file exists. Continuing..."
fi

# Temporary directory for generated files
TEMP_DIR="temp_graphs"
mkdir -p "$TEMP_DIR"

# generate graphs using plant_extra.py
while IFS=',' read -r col1 col2 col3 col4; do
  # Remove double quotes from input values
  col2_clean=$(echo $col2 | tr -d '"')
  col3_clean=$(echo $col3 | tr -d '"')
  col4_clean=$(echo $col4 | tr -d '"')

  echo "Processing row: col1=$col1, col2=$col2_clean, col3=$col3_clean, col4=$col4_clean"
  
  # Run plant_extra.py 
  python plant_extra.py \
    --plant "$col1" \
    --height $col2_clean \
    --leaf_count $col3_clean \
    --dry_weight $col4_clean 

  # Move the generated files to TEMP_DIR
  mv "${col1}_scatter.png" "$TEMP_DIR" 2>/dev/null
  mv "${col1}_histogram.png" "$TEMP_DIR" 2>/dev/null
  mv "${col1}_line_plot.png" "$TEMP_DIR" 2>/dev/null

done < "$CSV_FILE"

# for final compressed archive
TARGET_DIR="/Users/lootemtubul/Desktop/project_linux/LINUX_Course_Project/BACKUPS"
mkdir -p "$TARGET_DIR"

# Create a tar.gz archive of TEMP_DIR contents
BACKUP_NAME="$TARGET_DIR/Diagrams_$(date +%Y%m%d_%H%M%S).tar.gz"
echo "Creating a TAR.GZ archive of generated plots..."
tar -czf "$BACKUP_NAME" -C "$TEMP_DIR" .

# Remove temporary directory
rm -rf "$TEMP_DIR"

echo "Backup archive created at: $BACKUP_NAME"
echo "Script finished successfully."

exit 0