import type { Metadata } from "next";
import Link from "next/link";
import { ThemeToggle } from "@/components/theme-toggle";
import "./globals.css";

export const metadata: Metadata = {
  title: { default: "Cold & Flu Research Base", template: "%s · Cold & Flu Research Base" },
  description: "An evidence-led research base for respiratory self-care. No medical modules are currently published.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en-AU">
      <body>
        <noscript>
          <div className="noscript-banner" role="status">
            JavaScript is disabled, but the core information pages remain available.
          </div>
        </noscript>
        <a className="skip-link" href="#main">
          Skip to content
        </a>
        <header className="site-header">
          <Link href="/" className="brand">
            Cold & Flu Research Base
          </Link>
          <div className="site-header-actions">
            <nav aria-label="Primary">
              <Link href="/">Public status</Link>
              <Link href="/modules">Modules</Link>
              <Link href="/sources">Sources</Link>
              <Link href="/about/methodology">Methodology</Link>
              <Link href="/about/policy">Policy</Link>
              <Link href="/about/accessibility">Accessibility</Link>
              <Link href="/about/privacy">Privacy</Link>
              <Link href="/about/transparency">Transparency</Link>
              <Link href="/about/corrections">Corrections</Link>
            </nav>
            <ThemeToggle />
          </div>
        </header>
        <main id="main" className="shell" tabIndex={-1}>
          {children}
        </main>
        <footer>
          <p>Research project only. Not a diagnosis or substitute for professional care.</p>
        </footer>
      </body>
    </html>
  );
}
