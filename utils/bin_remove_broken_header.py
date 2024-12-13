import os
import shutil

def remove_first_16_bytes_from_file(file_path):
    # Read the original file
    with open(file_path, 'rb') as file:
        content = file.read()

    # Remove the first 16 bytes
    modified_content = content[16:]

    # Write the modified content back to the file
    with open(file_path, 'wb') as file:
        file.write(modified_content)

def process_files_in_directory(source_dir, dest_dir):
    # Ensure the destination directory exists
    os.makedirs(dest_dir, exist_ok=True)

    # Iterate over all files in the source directory
    for filename in os.listdir(source_dir):
        file_path = os.path.join(source_dir, filename)

        # Check if it's a file
        if os.path.isfile(file_path):
            # Remove the first 16 bytes from the file
            remove_first_16_bytes_from_file(file_path)

            # Move the modified file to the destination directory
            shutil.move(file_path, os.path.join(dest_dir, filename))

    print("First 16 bytes removed and files moved successfully.")

# Specify the source directory and destination directory
source_directory = '/Users/arsenijmeserakov/Downloads/test'  # Change this to your source directory
destination_directory = '/Users/arsenijmeserakov/Downloads/qqq'  # Change this to your destination directory

# Call the function to process files in the directory
process_files_in_directory(source_directory, destination_directory)
