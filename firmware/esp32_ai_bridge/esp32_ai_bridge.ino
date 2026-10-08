#include <Wire.h>
#include "mnist_infer.h"
#include <U8g2lib.h>
#include <Adafruit_NeoPixel.h>

// ---- Heltec WiFi Kit V3 pin map ----
#define OLED_SDA   17
#define OLED_SCL   18
#define OLED_RST   21
#define VEXT_CTRL  36
#define RGB_LED_PIN 48

U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, /* reset=*/ OLED_RST, /* clock=*/ OLED_SCL, /* data=*/ OLED_SDA);
Adafruit_NeoPixel pixel(1, RGB_LED_PIN, NEO_GRB + NEO_KHZ800);

// Buffer to hold the incoming 28x28 image from the Python Dashboard
uint8_t image_buffer[784];

void setLED(uint8_t r, uint8_t g, uint8_t b) {
  pixel.setPixelColor(0, pixel.Color(r, g, b));
  pixel.show();
}

void drawIdle() {
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_6x10_tf);
  u8g2.drawStr(0, 20, "ESP32 AI Bridge");
  u8g2.drawStr(0, 40, "Waiting for UI...");
  u8g2.sendBuffer();
  setLED(20, 20, 20); // Dim white idle state
}

void drawResult(int digit, uint32_t infer_us) {
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_logisoso32_tn);
  char buf[4];
  snprintf(buf, sizeof(buf), "%d", digit);
  u8g2.drawStr(4, 40, buf);

  u8g2.setFont(u8g2_font_6x10_tf);
  u8g2.setCursor(50, 20);
  u8g2.print("UI Uploaded");

  u8g2.setCursor(50, 40);
  u8g2.print(infer_us);
  u8g2.print(" us");
  
  u8g2.sendBuffer();
}

void setup() {
  // Start serial at the same baud rate the Streamlit UI uses
  Serial.begin(115200);
  Serial.setTimeout(2000); // Give enough time to receive all 784 bytes

  // Power on Vext for OLED
  pinMode(VEXT_CTRL, OUTPUT);
  digitalWrite(VEXT_CTRL, LOW);
  delay(50);

  pixel.begin();
  u8g2.begin();
  drawIdle();
}

void loop() {
  if (Serial.available() > 0) {
    int bytes_read = Serial.readBytes((char*)image_buffer, 784);
    
    if (bytes_read == 784) {
      setLED(0, 0, 80); // Blue during inference
      
      int32_t logits[10];
      uint32_t t0 = micros();
      int pred = mnist_infer(image_buffer, logits);
      uint32_t t1 = micros();
      
      // 1. Send prediction back to Dashboard
      Serial.print(pred);
      
      // 2. Display prediction on Heltec OLED and keep it there!
      drawResult(pred, t1 - t0);
      setLED(0, 60, 0); // Solid green
    } else {
      while(Serial.available()) Serial.read();
    }
  }
}