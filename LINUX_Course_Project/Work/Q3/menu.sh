#!/bin/bash

# Variable for the current CSV file
CSV_FILE=""

# Function to create a new CSV file
create_csv() {
    read -p "Enter the CSV file name (without extension): " filename
    CSV_FILE="${filename}.csv"
    echo "Plant,Height,Leaf Count,Dry Weight" > "$CSV_FILE"
    echo "File $CSV_FILE created and set as the current file."
}

# Function to select an existing CSV file
select_csv() {
    read -p "Enter the CSV file name to select (without extension): " filename
    CSV_FILE="${filename}.csv"
    if [[ -f "$CSV_FILE" ]]; then
        echo "File $CSV_FILE selected successfully."
    else
        echo "Error: File not found."
        CSV_FILE=""
    fi
}

# Function to display the current CSV file
show_csv() {
    if [[ -z "$CSV_FILE" ]]; then
        echo "No file selected."
        return
    fi
    cat "$CSV_FILE"
}

# Function to add a new row
add_row() {
    if [[ -z "$CSV_FILE" ]]; then
        echo "No file selected."
        return
    fi
    read -p "Enter plant name: " plant
    read -p "Enter heights (space-separated): " heights
    read -p "Enter leaf counts (space-separated): " leaves
    read -p "Enter dry weights (space-separated): " weight
    echo "$plant,\"$heights\",\"$leaves\",\"$weight\"" >> "$CSV_FILE"
    echo "Row added successfully!"
}

# Function to update a row by plant name
update_row() {
    if [[ -z "$CSV_FILE" ]]; then
        echo "No file selected."
        return
    fi
    read -p "Enter plant name to update: " name
    # Check if plant exists in the file
    plant_data=$(grep "^$name," "$CSV_FILE")
    if [[ -z "$plant_data" ]]; then
        echo "Error: Plant '$name' not found in the dataset."
        return
    fi
    # Ask for new values
    read -p "Enter new heights (space-separated): " new_heights
    read -p "Enter new leaf counts (space-separated): " new_leaves
    read -p "Enter new dry weights (space-separated): " new_weight
    # Create a temporary file
    temp_file=$(mktemp)
    # Read each line and replace the matching plant's row
    while IFS= read -r line; do
        if [[ "$line" =~ ^$name, ]]; then
            echo "$name,\"$new_heights\",\"$new_leaves\",\"$new_weight\"" >> "$temp_file"
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$CSV_FILE"
    # Replace the old file with the new updated file
    mv "$temp_file" "$CSV_FILE"
    echo "Row for plant '$name' updated successfully!"
}

# Function to delete a row by index or plant name
delete_row() {
    if [[ -z "$CSV_FILE" ]]; then
        echo "No file selected."
        return
    fi
    read -p "Enter row index to delete or plant name: " input
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        sed -i "${input}d" "$CSV_FILE"
        echo "Row deleted successfully!"
    else
        temp_file=$(mktemp)
        grep -v "^$input," "$CSV_FILE" > "$temp_file"
        mv "$temp_file" "$CSV_FILE"
        echo "Row for plant $input deleted successfully!"
    fi
}

# Function to find the plant with the highest average leaf count
find_max_leaf_count() {
    if [[ -z "$CSV_FILE" ]]; then
        echo "No file selected."
        return
    fi
    awk -F, '
    NR>1 {
        split($3, leaves, " ")
        sum = 0
        for (i in leaves) sum += leaves[i]
        avg = sum / length(leaves)
        if (avg > max_avg) {
            max_avg = avg
            max_plant = $1
        }
    }
    END { print "The plant with the highest average leaf count is:", max_plant }
    ' "$CSV_FILE"
}

# Function to run a Python script (for generating diagrams)
run_python_script() {
    if [[ -z "$CSV_FILE" ]]; then
        echo "No file selected."
        return
    fi

    read -p "Enter plant name: " plant

    # Find the plant data in the CSV file
    plant_data=$(grep "^$plant," "$CSV_FILE")

    if [[ -z "$plant_data" ]]; then
        echo "Error: Plant '$plant' not found in the dataset."
        return
    fi

    # Extract height, leaf count, and dry weight from CSV
    height=$(echo "$plant_data" | awk -F, '{print $2}' | tr -d '"')
    leaf_count=$(echo "$plant_data" | awk -F, '{print $3}' | tr -d '"')
    dry_weight=$(echo "$plant_data" | awk -F, '{print $4}' | tr -d '"')

    # Run the Python script with extracted data
    python3 plant_extra.py --plant "$plant" --height $height --leaf_count $leaf_count --dry_weight $dry_weight
}



# Main menu
while true; do
    echo "Select an action:"
    echo "1) Create a new CSV file and set it as the current file"
    echo "2) Select an existing CSV file"
    echo "3) Display the current CSV file"
    echo "4) Add a new row for a specific plant"
    echo "5) Run Python script with parameters for a specific plant to generate diagrams"
    echo "6) Update values in a specific row by plant name"
    echo "7) Delete a row by index or plant name"
    echo "8) Print the plant with the highest average leaf count"
    echo "9) Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1) create_csv ;;
        2) select_csv ;;
        3) show_csv ;;
        4) add_row ;;
        5) run_python_script ;;
        6) update_row ;;
        7) delete_row ;;
        8) find_max_leaf_count ;;
        9) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice, try again." ;;
    esac
done
