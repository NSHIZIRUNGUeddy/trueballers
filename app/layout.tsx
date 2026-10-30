import './globals.css';
import type { Metadata } from 'next';
export const metadata: Metadata = { title: 'True Ballers | Basketball News', description: 'Basketball news from Rwanda and around the world — in Kinyarwanda, English and French.' };
export default function RootLayout({children}:{children:React.ReactNode}) { return <html lang="rw"><body>{children}</body></html>; }
