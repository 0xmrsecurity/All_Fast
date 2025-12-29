#!/bin/bash
# Author -- 0xmrsecurity


# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Tool name banner
echo -e "${BLUE}*****************************************"
echo -e "*           GenUser_list.sh             *"
echo -e "*****************************************${NC}"

# Check if the input file is provided correctly
if [[ $# -ne 2 ]]; then
    echo -e "${RED}Usage: $0 -i input_user.lst${NC}"
    exit 1
fi

# Parse command-line argument for input file
while getopts "i:" opt; do
    case ${opt} in
        i )
            input_file=$OPTARG
            ;;
        * )
            echo -e "${RED}Usage: $0 -i input_user.lst${NC}"
            exit 1
            ;;
    esac
done

# Check if the input file exists and is readable
if [[ ! -f $input_file ]]; then
    echo -e "${RED}Error: Input file '$input_file' does not exist or is not readable.${NC}"
    exit 1
fi

# Create directory and navigate into it
echo -e "${GREEN}[*] Creating Directory...${NC}"
mkdir -p users && cd users || exit

# Read input user file and generate username variations
echo -e "${GREEN}[*] Generating username variations...${NC}"

variations=()  # Array to hold variations
output_index=1  # Output file index
output_file="var_user$output_index.lst"
> "$output_file"  # Create first output file

while IFS= read -r line; do
    names=($line)  # Split line by whitespace
    first="${names[0]}"
    last="${names[@]:1}"  # Concatenate all remaining parts for last name
    
    # Generate variations
    variations+=(
        "$first.$last"
        "$first$last"
        "${first:0:1}$last"
        "$first${last:0:1}"
        "$first_$last"
        "$first"
        "$last"
        "${first:0:1}.$last"
        "$first${last:0:1}"
        "${first:0:1}${last:0:1}"
        "$last${first:0:1}"
    )
done < "$input_file"

# Write variations to output files with a limit of 60 per file
for ((i=0; i<${#variations[@]}; i++)); do
    if (( i % 60 == 0 && i != 0 )); then
        ((output_index++))
        output_file="var_user$output_index.lst"
    fi
    echo "${variations[$i]}" >> "$output_file"
done

# Save total number of variations
total_variations=${#variations[@]}
total_var_output="total_var_user.lst"
echo "Total variations: $total_variations" > "$total_var_output"

# Provide the user with the command to run
echo -e "${GREEN}[*] You can run the following command for further processing:${NC}\n"
echo -e "${YELLOW}for i in users/var_user*.lst; do kerbrute userenum  -d DOMAIN.LOCAL --dc 10.10.10.10 \"\$i\" ; sleep 3; done | grep -i \"VALID USERNAME\"${NC}"

echo -e "${GREEN}[*] Finished.${NC}"
