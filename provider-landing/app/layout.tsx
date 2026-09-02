import type { Metadata } from 'next'; import './globals.css';
export const metadata: Metadata={title:'Serbisyo | Local services, made simple',description:'A Filipino marketplace where clients book trusted local services and professionals grow their business.'};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="en"><body>{children}</body></html>}
