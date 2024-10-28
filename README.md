# Project Report Script

This script generates a detailed report of the project, including the number of lines in various file types, the ratio of lines to files, and the project structure. It also provides options to view the report in different formats.

## Usage

To run the script, use the following command:

```bash
./reportproject.sh
```

## Configuration Guide

Before running the script, you can configure the following variables in the `reportproject.sh` file to customize the report generation:

1. **project_name**: Set the name of your project.
   ```bash
   project_name="Name_of_your_project"
   ```

2. **extensions**: List the file extensions to count.
   ```bash
   extensions=("js" "json" "jsx")
   ```

3. **ignore_directories**: List the directories to ignore.
   ```bash
   ignore_directories=("node_modules" "volumes" "dist" ".expo" ".vscode" "build" ".git")
   ```

4. **ignore_files**: List the files to ignore.
   ```bash
   ignore_files=("package-lock.json" "eas.json")
   ```

5. **ignore_blank_line**: Set to `true` to ignore blank lines.
   ```bash
   ignore_blank_line=true
   ```

6. **comments**: List the comment patterns to ignore.
   ```bash
   comments=("//" "#" "<!--")
   ```

7. **ignore_comment**: Set to `true` to ignore comments.
   ```bash
   ignore_comment=true
   ```

8. **output_file**: Set the name of the output report file.
   ```bash
   output_file="$project_name.report"
   ```

9. **create_csv**: Set to `true` to create a CSV output file.
   ```bash
   create_csv=false
   ```

10. **csv_output_file**: Set the name of the CSV output file.
    ```bash
    csv_output_file="$project_name.csv"
    ```

11. **MAX_RATIO**: Set the maximum ratio level (Red).
    ```bash
    MAX_RATIO=200
    ```

12. **MID_HIGH_RATIO**: Set the mid-high ratio level (Orange).
    ```bash
    MID_HIGH_RATIO=100
    ```

13. **MID_LOW_RATIO**: Set the mid-low ratio level (Orange).
    ```bash
    MID_LOW_RATIO=15
    ```

14. **MIN_RATIO**: Set the minimum ratio level (Red).
    ```bash
    MIN_RATIO=5
    ```


These variables allow you to customize the behavior of the script to suit your project's needs.


## Example

```bash
                      ### REPORT PROJECT Name_of_your_project ###

Ignored Directories:
node_modules
volumes
dist
.expo
.vscode
build
.git

Ignored Files:
package-lock.json
eas.json

Ignore Options:
Ignore Blank Lines: true
Ignore Comments: true
Comment Types: // # <!--

File Analysis:
sh

### SH FILES ###                                             | LINES
-------------------------------------------------------------------------
./reportproject.sh                                           | 186
-------------------------------------------------------------------------
Totals | files: 1                                            | 186
Ratio                                                        | 186

### TOTAL SUMMARY ###
-------------------------------------------------------------------------
Totals | files: 1                                            | 186
Ratio                                                        | 186
### PROJECT STRUCTURE ###
[ 192]  .
├── [1.1K]  Name_of_your_project.report
├── [ 359]  README
└── [7.5K]  reportproject.sh

1 directory, 3 files
Total size of files: 00 GB
Date and time start: 2024-10-28 17:17:40
Date and time end: 2024-10-28 17:17:40
Duration: 0 seconds
```
