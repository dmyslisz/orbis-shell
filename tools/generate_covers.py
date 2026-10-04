import os

covers = {
    'whats_new.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="wnGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#006FCD"/>
      <stop offset="50%" stop-color="#003791"/>
      <stop offset="100%" stop-color="#001844"/>
    </linearGradient>
  </defs>
  <rect width="512" height="512" fill="url(#wnGrad)"/>
  <circle cx="256" cy="220" r="110" fill="none" stroke="#ffffff" stroke-width="12" opacity="0.3"/>
  <rect x="180" y="160" width="152" height="120" rx="14" fill="#ffffff"/>
  <polygon points="300,280 340,320 280,320" fill="#ffffff"/>
  <line x1="205" y1="195" x2="275" y2="195" stroke="#003791" stroke-width="10" stroke-linecap="round"/>
  <line x1="205" y1="225" x2="305" y2="225" stroke="#003791" stroke-width="8" stroke-linecap="round"/>
  <line x1="205" y1="250" x2="260" y2="250" stroke="#003791" stroke-width="8" stroke-linecap="round"/>
  <text x="256" y="410" fill="#ffffff" font-size="42" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="2">WHAT'S NEW</text>
</svg>''',

    'steam.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="stGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1b2838"/>
      <stop offset="50%" stop-color="#171a21"/>
      <stop offset="100%" stop-color="#0d1217"/>
    </linearGradient>
  </defs>
  <rect width="512" height="512" fill="url(#stGrad)"/>
  <circle cx="256" cy="230" r="130" stroke="#66c0f4" stroke-width="16" fill="none"/>
  <circle cx="340" cy="170" r="45" stroke="#ffffff" stroke-width="16" fill="none"/>
  <circle cx="200" cy="290" r="32" stroke="#ffffff" stroke-width="14" fill="none"/>
  <line x1="210" y1="260" x2="280" y2="190" stroke="#66c0f4" stroke-width="16" stroke-linecap="round"/>
  <text x="256" y="420" fill="#66c0f4" font-size="44" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="4">STEAM</text>
</svg>''',

    'library.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="libGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1e3c72"/>
      <stop offset="100%" stop-color="#2a5298"/>
    </linearGradient>
  </defs>
  <rect width="512" height="512" fill="url(#libGrad)"/>
  <g transform="translate(146, 120)">
    <rect x="0" y="0" width="90" height="90" rx="12" fill="#ffffff"/>
    <rect x="120" y="0" width="90" height="90" rx="12" fill="#ffffff" opacity="0.85"/>
    <rect x="0" y="120" width="90" height="90" rx="12" fill="#ffffff" opacity="0.85"/>
    <rect x="120" y="120" width="90" height="90" rx="12" fill="#ffffff" opacity="0.65"/>
  </g>
  <text x="256" y="410" fill="#ffffff" font-size="42" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="2">LIBRARY</text>
</svg>''',

    'tv_video.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="tvGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#c31432"/>
      <stop offset="100%" stop-color="#240b36"/>
    </linearGradient>
  </defs>
  <rect width="512" height="512" fill="url(#tvGrad)"/>
  <rect x="126" y="130" width="260" height="170" rx="16" stroke="#ffffff" stroke-width="14" fill="none"/>
  <polygon points="230,175 305,215 230,255" fill="#ffffff"/>
  <line x1="200" y1="340" x2="312" y2="340" stroke="#ffffff" stroke-width="12" stroke-linecap="round"/>
  <line x1="256" y1="300" x2="256" y2="340" stroke="#ffffff" stroke-width="12"/>
  <text x="256" y="420" fill="#ffffff" font-size="40" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="2">TV &amp; VIDEO</text>
</svg>''',

    'browser.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="brGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0052D4"/>
      <stop offset="50%" stop-color="#4364F7"/>
      <stop offset="100%" stop-color="#6FB1FC"/>
    </linearGradient>
  </defs>
  <rect width="512" height="512" fill="url(#brGrad)"/>
  <circle cx="256" cy="220" r="100" stroke="#ffffff" stroke-width="12" fill="none"/>
  <ellipse cx="256" cy="220" rx="45" ry="100" stroke="#ffffff" stroke-width="10" fill="none"/>
  <line x1="156" y1="220" x2="356" y2="220" stroke="#ffffff" stroke-width="10"/>
  <text x="256" y="410" fill="#ffffff" font-size="38" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="2">INTERNET</text>
</svg>''',

    'gallery.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="galGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#11998e"/>
      <stop offset="100%" stop-color="#38ef7d"/>
    </linearGradient>
  </defs>
  <rect width="512" height="512" fill="url(#galGrad)"/>
  <rect x="126" y="130" width="260" height="180" rx="18" stroke="#ffffff" stroke-width="14" fill="none"/>
  <circle cx="185" cy="185" r="22" fill="#ffffff"/>
  <polygon points="150,285 220,205 270,250 310,210 365,285" fill="#ffffff"/>
  <text x="256" y="415" fill="#ffffff" font-size="36" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="2">CAPTURE GALLERY</text>
</svg>''',

    'retroarch.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="retroGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#232526"/>
      <stop offset="100%" stop-color="#414345"/>
    </linearGradient>
  </defs>
  <rect width="512" height="512" fill="url(#retroGrad)"/>
  <path d="M120 200 L180 200 L200 240 L312 240 L332 200 L392 200 L412 320 L352 320 L322 280 L190 280 L160 320 L100 320 Z" fill="#ffffff"/>
  <circle cx="180" cy="240" r="12" fill="#232526"/>
  <circle cx="332" cy="240" r="12" fill="#232526"/>
  <text x="256" y="415" fill="#ffffff" font-size="38" font-family="sans-serif" font-weight="bold" text-anchor="middle" letter-spacing="3">RETROARCH</text>
</svg>'''
}

out_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'assets', 'covers'))
os.makedirs(out_dir, exist_ok=True)
for name, svg in covers.items():
    p = os.path.join(out_dir, name)
    with open(p, 'w', encoding='utf-8') as f:
        f.write(svg)
    print('Generated cover:', name)

print('All covers generated successfully.')
