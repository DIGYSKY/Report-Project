#!/bin/bash
param=$1

# param for report
# Project name
   project_name="Name_of_your_project"
#  List of extensions to count
   extensions=("sh")
#  List of directories to ignore
   ignore_directories=("node_modules" "volumes" "dist" ".expo" ".vscode" "build" ".git")
#  List of files to ignore
   ignore_files=("package-lock.json" "eas.json")
#  ignore blank line
   ignore_blank_line=true
#  ignore comment
   comments=("//" "#" "<!--")
   ignore_comment=true
#  output file
   output_file="$project_name.report"
#  output csv
   create_csv=false
   csv_output_file="$project_name.csv"
# Ratio level
    MAX_RATIO=200 # Red
    MID_HIGH_RATIO=100 # Orange
    MID_LOW_RATIO=15 # Orange
    MIN_RATIO=5 # Red

RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

write_csv_header() {
  echo "Type,Files,Lines,Ratio" > "$csv_output_file"
}

if [ "$param" == "--view" ]; then
  cat $output_file
  exit 0
elif [ "$param" == "--csv" ]; then
  create_csv=true
else
  create_csv=false
fi

DATE_TIME_START=$(date +%s)

# Define functions at the beginning of the script
print_header() {
  local ext=$1
  printf "%-60s | %-10s\n" "### $ext FILES ###" "LINES"
  printf "%0.s-" {1..73}
  echo
}

print_row() {
  local file=$1
  local lines=$2
  local color=$3
  local extension=$4
  if [ "$create_csv" = true ]; then
    echo "$file,,$lines,$extension" >> "$csv_output_file"
  fi
  printf "${color}%-60s | %-10d${NC}\n" "$(truncate_string "$file" 60)" "$lines"
  printf "${color}%-60s | %-10d${NC}\n" "$(truncate_string "$file" 60)" "$lines" >> $output_file
}

print_total() {
  local total_files=$1
  local total_lines=$2
  local ratio=$3
  local color=$4
  local extension=$5
  printf "%0.s-" {1..73}
  echo
  if [ "$create_csv" = true ]; then
    echo "Totals,$total_files,$total_lines" >> "$csv_output_file"
    echo "Ratio,$ratio" >> "$csv_output_file"
  fi
  printf "%-60s | %-10d\n" "Totals | files: $total_files" "$total_lines"
  printf "${color}%-60s | %-10d${NC}\n" "Ratio" "$ratio"
  printf "%-60s | %-10d\n" "Totals | files: $total_files" "$total_lines" >> $output_file
  printf "${color}%-60s | %-10d${NC}\n" "Ratio" "$ratio" >> $output_file
}

truncate_string() {
  local str=$1
  local max_length=$2
  if [ ${#str} -gt $max_length ]; then
    echo "${str:0:$((max_length-3))}..."
  else
    echo "$str"
  fi
}

count_lines() {
  local file=$1
  local count
  local comment_patterns=""

  if [ "$ignore_comment" = true ]; then
    for comment in "${comments[@]}"; do
      comment_patterns+=" -e '^\s*$(echo "$comment" | sed 's/[\/]/\\\//g')'"
    done
  fi

  if [ "$ignore_blank_line" = true ] && [ "$ignore_comment" = true ]; then
    count=$(grep -v '^\s*$' "$file" | eval "grep -v $comment_patterns" | wc -l)
  elif [ "$ignore_blank_line" = true ]; then
    count=$(grep -cv '^\s*$' "$file")
  elif [ "$ignore_comment" = true ]; then
    count=$(eval "grep -v $comment_patterns" "$file" | wc -l)
  else
    count=$(wc -l < "$file")
  fi

  echo "$count"
}

# Usage:
#   ./ligne.sh [option]
#
# Options:
#   -a    Display all files with their line counts and color-coded ratios.
#
# This script counts the number of lines in JavaScript (.js) and JSX (.jsx) files
# in the current directory and its subdirectories, excluding specified directories.
# It then calculates the ratio of total lines to total files and color-codes the output
# based on predefined ratio levels.
#
# Color Rules:
#   Red: Ratio >= 200 or Ratio <= 3
#   Orange: 100 <= Ratio < 200 or Ratio < 10
#   Green: 10 <= Ratio < 100
#
# Example for a React Native project:
#  ./ligne.sh -a

ignore_args=()

# Add directory ignore arguments
for dir in "${ignore_directories[@]}"; do
  ignore_args+=(-not -path "./$dir/*")
done

# Add file ignore arguments
for file in "${ignore_files[@]}"; do
  ignore_args+=(-not -name "$file")
done

total_all_files=0
total_all_lines=0

if [ "$create_csv" = true ]; then
  write_csv_header
fi

echo -e "                      ${GREEN}### REPORT PROJECT $project_name ###${NC}"
echo -e "                      ${GREEN}### REPORT PROJECT $project_name ###${NC}" > $output_file

# Add information about ignored directories and files
echo -e "\n${ORANGE}Ignored Directories:${NC}" | tee -a $output_file
printf '%s\n' "${ignore_directories[@]}" | tee -a $output_file

echo -e "\n${ORANGE}Ignored Files:${NC}" | tee -a $output_file
printf '%s\n' "${ignore_files[@]}" | tee -a $output_file

# Add information about ignore options
echo -e "\n${ORANGE}Ignore Options:${NC}" | tee -a $output_file
echo "Ignore Blank Lines: $ignore_blank_line" | tee -a $output_file
echo "Ignore Comments: $ignore_comment" | tee -a $output_file
if [ "$ignore_comment" = true ]; then
    echo "Comment Types: ${comments[*]}" | tee -a $output_file
fi

echo -e "\n${GREEN}File Analysis:${NC}" | tee -a $output_file
echo -e "${extensions[@]}" | tee -a $output_file
echo ""

for ext in "${extensions[@]}"; do
  if [ -z "$ext" ]; then
    ext_upper="ALL FILES"
    file_pattern="*"
  else
    ext_upper=$(echo "$ext" | tr '[:lower:]' '[:upper:]')
    file_pattern="*.${ext}"
  fi
  
  print_header "$ext_upper"
  print_header "$ext_upper" >> $output_file
  
  total_files=0
  total_lines=0
  
  while IFS= read -r file; do
    lines=$(count_lines "$file")
    total_files=$((total_files + 1))
    total_lines=$((total_lines + lines))
    
    color=$GREEN
    if [ $lines -le $MIN_RATIO ] || [ $lines -ge $MAX_RATIO ]; then
      color=$RED
    elif [ $lines -le $MID_LOW_RATIO ] || [ $lines -ge $MID_HIGH_RATIO ]; then
      color=$ORANGE
    fi
    print_row "$file" "$lines" "$color" "$ext"
  done < <(find . "${ignore_args[@]}" -type f -name "$file_pattern")
  
  if [ $total_files -eq 0 ]; then
    ratio=0
  else
    ratio=$((total_lines / total_files))
  fi

  result_color=$GREEN
  if [ $ratio -ge $MAX_RATIO ] || [ $ratio -le $MIN_RATIO ]; then
    result_color=$RED
  elif [ $ratio -ge $MID_HIGH_RATIO ] || [ $ratio -le $MID_LOW_RATIO ]; then
    result_color=$ORANGE
  fi

  print_total "$total_files" "$total_lines" "$ratio" "$result_color" "$ext"
  echo
  
  total_all_files=$((total_all_files + total_files))
  total_all_lines=$((total_all_lines + total_lines))
done

total_ratio=$((total_all_lines / total_all_files))
total_ratio_color=$GREEN
if [ $total_ratio -ge $MAX_RATIO ] || [ $total_ratio -le $MIN_RATIO ]; then
  total_ratio_color=$RED
elif [ $total_ratio -ge $MID_HIGH_RATIO ] || [ $total_ratio -le $MID_LOW_RATIO ]; then
  total_ratio_color=$ORANGE
fi

echo "### TOTAL SUMMARY ###"
echo "### TOTAL SUMMARY ###" >> $output_file
print_total "$total_all_files" "$total_all_lines" "$total_ratio" "$total_ratio_color" "Grand Total"

# Generate the tree command with ignored directories
ignore_dirs=$(printf " -I %s" "${ignore_directories[@]}")
tree_command="tree -hs $ignore_dirs --dirsfirst --charset utf-8"

# Execute the tree command and write the output to the report file
echo "### PROJECT STRUCTURE ###" >> $output_file
$tree_command >> $output_file

# Display the tree command output
echo "### PROJECT STRUCTURE ###"
$tree_command

# Calculate total size excluding ignored directories and convert to GB
total_size_kb=$(find . \( $(printf "! -path './%s/*' " "${ignore_directories[@]}") \) -type f -print0 | xargs -0 du -k | awk '{sum+=$1} END {print sum}')
total_size_gb=$(echo "scale=2; $total_size_kb/1024/1024" | bc)
echo "Total size of files: 0${total_size_gb} GB"
echo "Total size of files: 0${total_size_gb} GB" >> $output_file

DATE_TIME_END=$(date +%s)
DURATION=$((DATE_TIME_END - DATE_TIME_START))
echo "Date and time start: $(date -r $DATE_TIME_START '+%Y-%m-%d %H:%M:%S')"
echo "Date and time end: $(date -r $DATE_TIME_END '+%Y-%m-%d %H:%M:%S')"
echo "Duration: $DURATION seconds"
