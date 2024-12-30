from PIL import Image

def replace_non_white_with_magenta(input_image_path, output_image_path):
    # Open the image
    img = Image.open(input_image_path)
    img = img.convert("RGBA")  # Ensure the image is in RGBA format

    # Create a new image to store the modified pixels
    new_img = Image.new("RGBA", img.size)

    # Define the magenta color
    magenta = (0, 0, 0, 255)  # RGBA for magenta

    # Iterate through each pixel
    for x in range(img.width):
        for y in range(img.height):
            pixel = img.getpixel((x, y))
            # Check if the pixel is not white
            if pixel[0] != 255 or pixel[1] != 255 or pixel[2] != 255:  # RGB values for white
                new_img.putpixel((x, y), magenta)  # Replace with magenta
            else:
                new_img.putpixel((x, y), pixel)  # Keep the original pixel

    # Save the new image
    new_img.save(output_image_path)

# Example usage
input_image = 'input.png'  # Path to your input image
output_image = 'output.png'  # Path to save the output image
replace_non_white_with_magenta(input_image, output_image)
