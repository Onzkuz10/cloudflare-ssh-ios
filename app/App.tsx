import React, { useState } from 'react';
import {
  SafeAreaView,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  ActivityIndicator,
} from 'react-native';
import { CFTunnel } from './src/modules/CFTunnel';

export default function App() {
  const [hostname, setHostname] = useState('ssh.example.com');
  const [result, setResult] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handlePing = async () => {
    setLoading(true);
    setResult(null);
    setError(null);
    try {
      const res = await CFTunnel.ping(hostname);
      setResult(res);
    } catch (e: any) {
      setError(e.message ?? 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>Cloudflare SSH</Text>
      <Text style={styles.subtitle}>Phase 1 — Go bridge smoke test</Text>

      <View style={styles.card}>
        <Text style={styles.label}>Hostname</Text>
        <TextInput
          style={styles.input}
          value={hostname}
          onChangeText={setHostname}
          autoCapitalize="none"
          autoCorrect={false}
          placeholder="ssh.example.com"
          placeholderTextColor="#666"
        />
        <TouchableOpacity style={styles.button} onPress={handlePing} disabled={loading}>
          {loading
            ? <ActivityIndicator color="#fff" />
            : <Text style={styles.buttonText}>Ping Go Bridge</Text>
          }
        </TouchableOpacity>
      </View>

      {result && (
        <View style={styles.resultBox}>
          <Text style={styles.resultLabel}>✅ Response</Text>
          <Text style={styles.resultText}>{result}</Text>
        </View>
      )}

      {error && (
        <View style={[styles.resultBox, styles.errorBox]}>
          <Text style={styles.resultLabel}>❌ Error</Text>
          <Text style={styles.resultText}>{error}</Text>
        </View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0a0a0a', padding: 24 },
  title: { color: '#fff', fontSize: 24, fontWeight: '700', marginBottom: 4 },
  subtitle: { color: '#666', fontSize: 14, marginBottom: 32 },
  card: { backgroundColor: '#1a1a1a', borderRadius: 12, padding: 16, gap: 12 },
  label: { color: '#aaa', fontSize: 12, textTransform: 'uppercase', letterSpacing: 1 },
  input: {
    backgroundColor: '#2a2a2a', borderRadius: 8, padding: 12,
    color: '#fff', fontSize: 16, fontFamily: 'Menlo',
  },
  button: {
    backgroundColor: '#f6821f', borderRadius: 8, padding: 14,
    alignItems: 'center',
  },
  buttonText: { color: '#fff', fontWeight: '600', fontSize: 16 },
  resultBox: {
    marginTop: 24, backgroundColor: '#1a1a1a', borderRadius: 12,
    padding: 16, gap: 8,
  },
  errorBox: { borderWidth: 1, borderColor: '#ff4444' },
  resultLabel: { color: '#aaa', fontSize: 12, textTransform: 'uppercase', letterSpacing: 1 },
  resultText: { color: '#fff', fontFamily: 'Menlo', fontSize: 14, lineHeight: 20 },
});
