#include "mnist_infer.h"

// ESP32 DevKit firmware for the Streamlit handwritten-digit dashboard.
// Serial protocol:
//   PC -> ESP32: 784 raw pixel bytes
//   ESP32 -> PC: one ASCII digit ('0' through '9')
// Do not print debug messages to Serial while the dashboard is connected.

static constexpr uint32_t SERIAL_BAUD = 115200;
static constexpr size_t IMAGE_SIZE = 784;
static constexpr uint32_t SERIAL_READ_TIMEOUT_MS = 2000;

uint8_t image_buffer[IMAGE_SIZE];

void setup() {
  Serial.begin(SERIAL_BAUD);
  Serial.setTimeout(SERIAL_READ_TIMEOUT_MS);
}

void loop() {
  if (Serial.available() <= 0) {
    return;
  }

  const size_t bytes_read = Serial.readBytes(
      reinterpret_cast<char*>(image_buffer),
      IMAGE_SIZE
  );

  if (bytes_read != IMAGE_SIZE) {
    while (Serial.available() > 0) {
      Serial.read();
    }
    return;
  }

  int32_t logits[10];
  const int prediction = mnist_infer(image_buffer, logits);

  // The dashboard reads one byte, so send only the predicted digit.
  if (prediction >= 0 && prediction <= 9) {
    Serial.write(static_cast<uint8_t>('0' + prediction));
  }
}
