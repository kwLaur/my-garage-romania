import { useState } from 'react';
import type { FormEvent } from 'react';
import { api, authStore } from '../lib/api';
import AppleButton from '../components/AppleButton';
import AppleCard from '../components/AppleCard';

export default function LoginPage({ onLogin }: { onLogin: () => void }) {
  const [email, setEmail] = useState('admin@garage.local');
  const [password, setPassword] = useState('garage123');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function submit(event: FormEvent) {
    event.preventDefault();
    setLoading(true);
    setError('');
    try {
      const response = await api.login(email, password);
      authStore.setToken(response.token);
      onLogin();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login failed');
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="flex min-h-screen items-center justify-center bg-[#f5f5f7] px-4">
      <div className="w-full max-w-md">
        <div className="mb-8 text-center">
          <h1 className="text-4xl font-semibold tracking-normal text-slate-950">My Garage Romania</h1>
          <p className="mt-3 text-slate-500">A quiet cockpit for your personal cars.</p>
        </div>
        <AppleCard>
          <form onSubmit={submit} className="space-y-4">
            <div className="space-y-2">
              <label>Email</label>
              <input className="w-full" value={email} onChange={(event) => setEmail(event.target.value)} />
            </div>
            <div className="space-y-2">
              <label>Password</label>
              <input className="w-full" type="password" value={password} onChange={(event) => setPassword(event.target.value)} />
            </div>
            {error && <div className="rounded-2xl bg-red-50 px-4 py-3 text-sm text-red-700">{error}</div>}
            <AppleButton className="w-full" disabled={loading}>{loading ? 'Signing in...' : 'Sign in'}</AppleButton>
          </form>
        </AppleCard>
      </div>
    </main>
  );
}
