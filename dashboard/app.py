import streamlit as st
import serial
from PIL import Image, ImageOps
import time

# --- HARDWARE CONFIGURATION ---
COM_PORT = 'COM5'  # <-- CHANGE THIS TO YOUR ESP32's COM PORT!
BAUD_RATE = 115200

st.set_page_config(page_title="Hardware AI Benchmark", layout="centered")
st.title("Edge AI Hardware Dashboard 🚀")
st.write("Upload a handwritten digit (0-9) to run live inference on your Heltec ESP32-S3.")

# 1. Image Upload
uploaded_file = st.file_uploader("Upload an image", type=["png", "jpg", "jpeg"])

if uploaded_file is not None:
    # 2. Image Processing (Format for MNIST)
    # Convert to Grayscale
    img = Image.open(uploaded_file).convert('L')
    
    # Resize to exactly 28x28 pixels
    img = img.resize((28, 28))
    
    # Invert colors (MNIST is white numbers on a black background)
    # If your images are already white-on-black, comment the next line out.
    img = ImageOps.invert(img)
    
    st.image(img, caption="Processed 28x28 Input Sent to Hardware", width=150)
    
    # Convert image to raw 784-byte array
    pixel_data = list(img.getdata())
    raw_bytes = bytearray(pixel_data)

    # 3. Hardware Communication
    if st.button("⚡ Run on ESP32"):
        try:
            # Open serial port (Ensure Arduino Serial Monitor is closed!)
            with serial.Serial(COM_PORT, BAUD_RATE, timeout=2) as ser:
                start_time = time.time()
                
                # Send all 784 bytes down the USB cable
                ser.write(raw_bytes)
                
                # Wait for the single ASCII character response
                result = ser.read(1)
                
                latency = (time.time() - start_time) * 1000 # Convert to ms
                
                if result:
                    prediction = result.decode('utf-8')
                    st.success(f"### 🎯 Hardware Prediction: {prediction}")
                    st.caption(f"End-to-End Latency: ~{latency:.2f} ms")
                else:
                    st.error("Hardware timeout. Is the ESP32 plugged in and using the right COM port?")
        except serial.SerialException as e:
            st.error(f"Serial Error: Cannot connect to {COM_PORT}.")
            st.warning("⚠️ Make sure the Arduino IDE Serial Monitor is CLOSED. Windows only allows one program to use a COM port at a time.")