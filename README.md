\# ESP32 MNIST Hardware AI



Real-time handwritten digit recognition using a Heltec WiFi Kit V3 ESP32-S3, an integer neural-network inference engine, and a local Streamlit web dashboard.



\## System Architecture



User

&#x20; ↓

Streamlit Web Dashboard

&#x20; ↓

Image Preprocessing

&#x20; ↓

28 × 28 MNIST Input

&#x20; ↓

784 Quantized Pixels

&#x20; ↓

USB Serial

&#x20; ↓

Heltec ESP32-S3

&#x20; ↓

784 → 32 → 16 → 10 MLP

&#x20; ↓

Digit Prediction

&#x20; ↓

OLED + Web Dashboard



\## Hardware



\- Heltec WiFi Kit V3

\- ESP32-S3

\- Onboard SSD1306 OLED

\- USB serial connection



\## Neural Network



Architecture:



784 → 32 → 16 → 10



The ESP32 implementation uses:



\- Integer arithmetic

\- INT8 weights

\- INT32 accumulation

\- ReLU

\- Fixed-point requantization

\- Multiplier and shift constants

\- Output argmax



The ESP32 inference implementation follows the FPGA golden-reference model.



\## FPGA Reference



The `fpga\_reference` directory contains the original VSDSquadron FM implementation, including:



\- Verilog RTL

\- Quantized weights

\- Bias values

\- Model file

\- Sample data

\- FPGA build files

\- Workshop documentation



\## Web Dashboard



The Streamlit dashboard runs locally on the Windows PC connected to the ESP32.



The PC performs:



1\. Image upload

2\. Grayscale conversion

3\. Image resizing

4\. MNIST preprocessing

5\. Serial transmission



The ESP32 performs the neural-network inference.



\## Windows Serial Communication



Current ESP32 port:



COM5



Baud rate:



115200



\## Running the Dashboard



Open PowerShell:



cd dashboard



Install dependencies:



python -m pip install -r requirements.txt



Start the dashboard:



python -m streamlit run app.py



Or:



.\\start\_dashboard.ps1



The dashboard opens at:



http://localhost:8501



\## Hardware Test



1\. Connect the Heltec ESP32-S3.

2\. Confirm the Windows COM port.

3\. Close Arduino Serial Monitor.

4\. Start the Streamlit dashboard.

5\. Upload a handwritten digit.

6\. Press Run on ESP32.

7\. Observe the prediction on the dashboard.

8\. Observe the prediction on the Heltec OLED.



\## Project Components



\### ESP32 Firmware



Location:



firmware/esp32\_ai\_bridge/



\### Streamlit Dashboard



Location:



dashboard/



\### FPGA Reference



Location:



fpga\_reference/



\### Test Images



Location:



test\_images/



\### Utilities



Location:



tools/



\## Model Flow



Input image



28 × 28



↓



784 input values



↓



Layer 1



784 → 32



↓



ReLU + requantization



↓



Layer 2



32 → 16



↓



ReLU + requantization



↓



Layer 3



16 → 10



↓



Argmax



↓



Predicted digit

