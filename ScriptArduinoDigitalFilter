// ———————— Configuration ———————— 
const int sensorPin       = 1;       // ADC1_6
const unsigned long interval = 1;     // ms → Fs ≈ 1000 Hz

// —————— Filter parameters (50 Hz cutoff) —————— 
// Δt = interval (ms) → seconds
const float dt    = interval * 1e-3f;               // 0.001 s
const float RC    = 1.0f / (2.0f * PI * 50.0f);      // ≈0.003183 s
const float alpha = RC / (RC + dt);                 // ≈0.7609

// filter state
float prevRaw      = 0.0f;
float prevFiltered = 0.0f;

void setup() {
  Serial.begin(115200);
  delay(2000); // give host time to open port
}

void loop() {
  static unsigned long last = 0;
  unsigned long now = millis();
  if (now - last < interval) return;
  last = now;

  // 1) Read and scale
  int   rawADC = analogRead(sensorPin);
  float raw    = rawADC * (3.3f / 4095.0f);
    // 2) High‑pass IIR: y[n] = α ( y[n‑1] + x[n] − x[n‑1] )
  float filtered = alpha * (prevFiltered + raw - prevRaw);
  prevRaw      = raw;
  prevFiltered = filtered;

  // 3) Transmit “raw,filtered”
  //Serial.print(raw, 4);
  //Serial.print(',');
  Serial.println(filtered, 4);
}
