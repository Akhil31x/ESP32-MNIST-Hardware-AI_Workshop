#include "mnist_infer.h"

// NodeMCU V3 (ESP8266MOD) firmware for the shared MNIST dashboard.
// Protocol kept compatible with app.py:
//   PC -> board: 784 raw pixel bytes
//   board -> PC: one ASCII digit ('0' through '9')
//
// Do not print debug text to Serial while the dashboard is connected.

static const uint32_t SERIAL_BAUD = 115200;
static const size_t IMAGE_SIZE = 784;
static const uint32_t SERIAL_READ_TIMEOUT_MS = 2500;

uint8_t image_buffer[IMAGE_SIZE];

void setup() {
  Serial.begin(SERIAL_BAUD);
  Serial.setTimeout(SERIAL_READ_TIMEOUT_MS);
  delay(100);
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

  if (prediction >= 0 && prediction <= 9) {
    Serial.write(static_cast<uint8_t>('0' + prediction));
  }
}
