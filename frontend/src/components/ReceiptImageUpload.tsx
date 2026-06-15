import { Upload } from 'lucide-react';

export default function ReceiptImageUpload({ onFile }: { onFile: (file: File | null) => void }) {
  return (
    <label className="flex cursor-pointer flex-col items-center justify-center rounded-apple border border-dashed border-slate-300 bg-slate-50 px-4 py-8 text-center normal-case tracking-normal text-slate-500">
      <Upload size={24} />
      <span className="mt-3 text-sm font-medium">Upload receipt image</span>
      <span className="mt-1 text-xs">JPEG, PNG, WEBP up to 5 MB</span>
      <input className="hidden" type="file" accept="image/png,image/jpeg,image/webp" onChange={(event) => onFile(event.target.files?.[0] ?? null)} />
    </label>
  );
}
