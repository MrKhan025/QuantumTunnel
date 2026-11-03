import React from 'react';
import { TelemetryDashboard } from './components/TelemetryDashboard';

export default function App() {
  return (
    <main style={{ fontFamily: 'system-ui', padding: '2rem', background: '#0b0f19', color: '#f8fafc' }}>
      <h1>QuantumTunnel Zero-Trust Enterprise Console</h1>
      <p>Protocol: WireGuard + ML-KEM-1024 Hybrid PSK | OpenVPN TLS 1.3 Fallback | No-Log Enforced</p>
      <TelemetryDashboard />
    </main>
  );
}
