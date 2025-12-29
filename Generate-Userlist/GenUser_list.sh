#!/bin/bash
#Authoe  0xmrsecurity
# ================= Colors =================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ================= Banner =================
echo -e "${BLUE}*****************************************"
echo -e "*           GenUser_list.sh             *"
echo -e "*****************************************${NC}"

# ================= Usage Check =================
if [[ $# -ne 2 ]]; then
    echo -e "${RED}Usage: $0 -i input_user.lst${NC}"
    exit 1
fi

# ================= Parse Args =================
while getopts "i:" opt; do
    case ${opt} in
        i) input_file="$OPTARG" ;;
        *)
            echo -e "${RED}Usage: $0 -i input_user.lst${NC}"
            exit 1
            ;;
    esac
done

# ================= Validate Input File =================
if [[ ! -f "$input_file" || ! -r "$input_file" ]]; then
    echo -e "${RED}Error: Input file '$input_file' does not exist or is not readable.${NC}"
    exit 1
fi

# Convert to absolute path
input_file="$(realpath "$input_file")"

# ================= Create Output Dir =================
echo -e "${GREEN}[*] Creating Directory...${NC}"
mkdir -p users || exit 1
cd users || exit 1

# ================= Generate Variations =================
echo -e "${GREEN}[*] Generating username variations...${NC}"

tmp_file="$(mktemp)"
> "$tmp_file"

while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" ]] && continue

    names=($line)
    first="${names[0]}"
    last="${names[@]:1}"

    cat <<EOF >> "$tmp_file"
${first}.${last}
${first}${last}
${first:0:1}${last}
${first}${last:0:1}
${first}_${last}
${first}
${last}
${first:0:1}.${last}
${first:0:1}${last:0:1}
${last}${first:0:1}
EOF
done < "$input_file"

# ================= Deduplicate =================
mapfile -t variations < <(sort -u "$tmp_file")
rm -f "$tmp_file"

# ================= Write Output Files (60 per file) =================
output_index=1
output_file="var_user${output_index}.lst"
> "$output_file"

for ((i=0; i<${#variations[@]}; i++)); do
    if (( i % 60 == 0 && i != 0 )); then
        ((output_index++))
        output_file="var_user${output_index}.lst"
        > "$output_file"
    fi
    echo "${variations[$i]}" >> "$output_file"
done

# ================= Summary =================
total_variations="${#variations[@]}"
echo "Total variations: $total_variations" > total_var_user.lst

# ================= Kerbrute Hint =================
echo -e "\n${GREEN}[*] You can run the following command for further processing:${NC}\n"
echo -e "${YELLOW}for i in users/var_user*.lst; do kerbrute userenum -d DOMAIN.LOCAL --dc 10.10.10.10 \"\$i\"; sleep 3; done | grep -i \"VALID USERNAME\"${NC}"
echo -e " "
echo -e "[*] Your output file saved in users directory.."
echo -e "\n${GREEN}[*] Finished.${NC}"
