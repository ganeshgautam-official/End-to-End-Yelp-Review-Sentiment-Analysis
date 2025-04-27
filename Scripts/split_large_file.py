# File path and split parameters
input_file = "yelp_academic_dataset_review.json"  
output_prefix = "split_json_"                    
num_files = 10                                   

# Step 1: Count total number of lines (each line is a JSON object)
with open(input_file, "r", encoding="utf8") as f:
    total_lines = sum(1 for _ in f)

print(f"Total lines: {total_lines}")

# Step 2: Calculate lines per output file
lines_per_file = total_lines // num_files

print(f"Lines per file: {lines_per_file}")

# Step 3: Split the input file into multiple smaller files
with open(input_file, "r", encoding="utf8") as f:
    for i in range(num_files):
        output_filename = f"{output_prefix}{i + 1}.json"
        
        # Open a new output file for writing
        with open(output_filename, "w", encoding="utf8") as outfile:
            for _ in range(lines_per_file):
                line = f.readline()
                if not line:
                    break  
                outfile.write(line)

print("JSON file successfully split into smaller parts!")
