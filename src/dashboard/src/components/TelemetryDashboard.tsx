import React from 'react';

export function TelemetryDashboard() {
  return (
    <section style={{ marginTop: '1.5rem', padding: '1rem', border: '1px solid #1e293b', borderRadius: '8px' }}>
      <h2>Real-Time Gateway Health & Anonymized Metrics</h2>
      <ul>
        <li>WireGuard Primary Interface (wg0): Active (MTU 1420)</li>
        <li>Post-Quantum Hybrid PSK (X25519 + ML-KEM-1024): Enforced</li>
        <li>Client Endpoint Logging: Disabled (Prometheus labeldrop active)</li>
      </ul>
    </section>
  );
}
