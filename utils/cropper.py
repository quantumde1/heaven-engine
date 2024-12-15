import os
from PIL import Image

# Define the target size
target_size = (1598, 955)

# Get the current directory
current_dir = os.getcwd()

# Loop through all files in the current directory
for filename in os.listdir(current_dir):
    if filename.endswith('.png'):
        # Open the image
        img_path = os.path.join(current_dir, filename)
        with Image.open(img_path) as img:
            # Calculate the cropping box
            left = (img.width - target_size[0]) / 2
            top = (img.height - target_size[1]) / 2
            right = (img.width + target_size[0]) / 2
            bottom = (img.height + target_size[1]) / 2
            
            # Ensure the cropping box is within the image dimensions
            if left < 0 or top < 0 or right > img.width or bottom > img.height:
                print(f"Image {filename} is too small to crop to {target_size}. Skipping.")
                continue
            
            # Crop the image
            cropped_img = img.crop((left, top, right, bottom))
            
            # Save the cropped image (you can change the filename if needed)
            cropped_img.save(os.path.join(current_dir, f'cropped_{filename}'))
            print(f"Cropped image saved as cropped_{filename}")

