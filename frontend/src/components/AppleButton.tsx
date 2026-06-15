import type { ButtonHTMLAttributes, PropsWithChildren } from 'react';

type Props = PropsWithChildren<ButtonHTMLAttributes<HTMLButtonElement> & { variant?: 'primary' | 'secondary' | 'ghost' }>;

export default function AppleButton({ children, className = '', variant = 'primary', ...props }: Props) {
  const styles = {
    primary: 'bg-slate-950 text-white shadow-lg shadow-slate-950/10 hover:bg-slate-800',
    secondary: 'bg-white text-slate-900 ring-1 ring-slate-200 hover:bg-slate-50',
    ghost: 'text-slate-600 hover:bg-slate-100'
  };
  return (
    <button
      className={`inline-flex min-h-11 items-center justify-center gap-2 rounded-2xl px-4 py-2 text-sm font-semibold transition disabled:cursor-not-allowed disabled:opacity-50 ${styles[variant]} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
