import type { PropsWithChildren } from 'react';

type Props = PropsWithChildren<{ className?: string }>;

export default function AppleCard({ children, className = '' }: Props) {
  return <section className={`rounded-apple bg-white p-6 shadow-apple ring-1 ring-slate-200/60 ${className}`}>{children}</section>;
}
