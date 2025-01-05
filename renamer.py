import os

# Define the folder path
folder = r"C:/Programming/Codes/Python/Extra/style-transfer-project/Dataset/Artist-work/Albrecht_Durer"

# Extract folder name from the path
folder_name = os.path.basename(folder)

# Get a list of files and sort them to ensure order
files = sorted(os.listdir(folder))

# Loop through the files and rename them
for index, file in enumerate(files, start=1):
    file_path = os.path.join(folder, file)
    
    # Ensure it's a file and not a subdirectory
    if os.path.isfile(file_path):
        # Get the file extension
        file_extension = os.path.splitext(file)[1]
        
        # Create the new file name
        new_name = f"{folder_name}_{index}{file_extension}"
        
        # Generate the full path for the new file name
        new_file_path = os.path.join(folder, new_name)
        
        # Rename the file
        os.rename(file_path, new_file_path)
        print(f"Renamed: {file} -> {new_name}")

print("Renaming completed!")
