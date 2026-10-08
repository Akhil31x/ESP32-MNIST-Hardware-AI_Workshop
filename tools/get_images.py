from PIL import Image, ImageOps
import os

# Path to your existing samples file
mem_file = "VSDSquadron_FM_Handwritten_Digit_AI_FPGA_Pack/samples_all.mem"

with open(mem_file, "r") as f:
    tokens = f.read().split()

print("Extracting images...")

# Extract the first 20 images (which includes 3, 5, 7, and 9)
for i in range(20):
    # Convert hex back to integer pixels
    pixels = [int(p, 16) for p in tokens[i*784 : (i+1)*784]]
    
    img = Image.new('L', (28, 28))
    img.putdata(pixels)
    
    # Invert to make it black ink on white paper for the UI
    img = ImageOps.invert(img) 
    
    filename = f"sample_{i}.png"
    img.save(filename)
    print(f"Saved {filename}")

print("Done! Look in your folder.")