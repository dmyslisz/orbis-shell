import os

icons = {
    'trophy_platinum.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <defs>
    <linearGradient id="plat" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#e0f7fa"/>
      <stop offset="50%" stop-color="#80deea"/>
      <stop offset="100%" stop-color="#0097a7"/>
    </linearGradient>
  </defs>
  <path d="M50 8H14c-3 0-5.5 2.5-5.5 5.5v5.5c0 7.2 5.3 13.1 12.3 14 1.8 4.2 4.9 7.7 9.2 9.2V48H22v6h20v-6h-8v-5.8c4.3-1.5 7.4-5 9.2-9.2 7-.9 12.3-6.8 12.3-14v-5.5C55.5 10.5 53 8 50 8zM14 19v-5.5h5.5v10.1C16.4 22.5 14 20.9 14 19zm36 0c0 1.9-2.4 3.5-5.5 4.6V13.5H50V19z" fill="url(#plat)"/>
  <polygon points="32,16 35,23 42,23 36,28 38,35 32,31 26,35 28,28 22,23 29,23" fill="#ffffff" opacity="0.9"/>
</svg>''',

    'trophy_gold.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <defs>
    <linearGradient id="gold" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#fff59d"/>
      <stop offset="50%" stop-color="#fbc02d"/>
      <stop offset="100%" stop-color="#f57f17"/>
    </linearGradient>
  </defs>
  <path d="M50 8H14c-3 0-5.5 2.5-5.5 5.5v5.5c0 7.2 5.3 13.1 12.3 14 1.8 4.2 4.9 7.7 9.2 9.2V48H22v6h20v-6h-8v-5.8c4.3-1.5 7.4-5 9.2-9.2 7-.9 12.3-6.8 12.3-14v-5.5C55.5 10.5 53 8 50 8zM14 19v-5.5h5.5v10.1C16.4 22.5 14 20.9 14 19zm36 0c0 1.9-2.4 3.5-5.5 4.6V13.5H50V19z" fill="url(#gold)"/>
</svg>''',

    'trophy_silver.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <defs>
    <linearGradient id="silv" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#ffffff"/>
      <stop offset="50%" stop-color="#cfd8dc"/>
      <stop offset="100%" stop-color="#90a4ae"/>
    </linearGradient>
  </defs>
  <path d="M50 8H14c-3 0-5.5 2.5-5.5 5.5v5.5c0 7.2 5.3 13.1 12.3 14 1.8 4.2 4.9 7.7 9.2 9.2V48H22v6h20v-6h-8v-5.8c4.3-1.5 7.4-5 9.2-9.2 7-.9 12.3-6.8 12.3-14v-5.5C55.5 10.5 53 8 50 8zM14 19v-5.5h5.5v10.1C16.4 22.5 14 20.9 14 19zm36 0c0 1.9-2.4 3.5-5.5 4.6V13.5H50V19z" fill="url(#silv)"/>
</svg>''',

    'trophy_bronze.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <defs>
    <linearGradient id="brz" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#ffccbc"/>
      <stop offset="50%" stop-color="#d7ccc8"/>
      <stop offset="100%" stop-color="#8d6e63"/>
    </linearGradient>
  </defs>
  <path d="M50 8H14c-3 0-5.5 2.5-5.5 5.5v5.5c0 7.2 5.3 13.1 12.3 14 1.8 4.2 4.9 7.7 9.2 9.2V48H22v6h20v-6h-8v-5.8c4.3-1.5 7.4-5 9.2-9.2 7-.9 12.3-6.8 12.3-14v-5.5C55.5 10.5 53 8 50 8zM14 19v-5.5h5.5v10.1C16.4 22.5 14 20.9 14 19zm36 0c0 1.9-2.4 3.5-5.5 4.6V13.5H50V19z" fill="url(#brz)"/>
</svg>''',

    'disc.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
  <circle cx="24" cy="24" r="20" stroke="#ffffff" stroke-width="2.5"/>
  <circle cx="24" cy="24" r="6" stroke="#ffffff" stroke-width="2.5"/>
  <path d="M24 4 A 20 20 0 0 1 38 10" stroke="rgba(255,255,255,0.7)" stroke-width="3" stroke-linecap="round"/>
</svg>''',

    'whats_new.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <rect x="8" y="10" width="48" height="44" rx="6" stroke="#ffffff" stroke-width="3"/>
  <line x1="16" y1="22" x2="48" y2="22" stroke="#ffffff" stroke-width="3" stroke-linecap="round"/>
  <line x1="16" y1="32" x2="38" y2="32" stroke="#ffffff" stroke-width="2.5" stroke-linecap="round"/>
  <line x1="16" y1="42" x2="32" y2="42" stroke="#ffffff" stroke-width="2.5" stroke-linecap="round"/>
  <polygon points="44,36 50,42 44,48" fill="#ffffff"/>
</svg>''',

    'tv_video.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none">
  <rect x="6" y="12" width="52" height="36" rx="5" stroke="#ffffff" stroke-width="3"/>
  <path d="M20 54h24" stroke="#ffffff" stroke-width="3" stroke-linecap="round"/>
  <path d="M32 48v6" stroke="#ffffff" stroke-width="3"/>
  <polygon points="27,23 41,30 27,37" fill="#ffffff"/>
</svg>''',

    'rest_mode.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
  <path d="M34 26A14 14 0 1 1 22 14a12 12 0 0 0 12 12z" stroke="#ffa726" stroke-width="3" fill="#ffa726" fill-opacity="0.2" stroke-linejoin="round"/>
  <path d="M36 10l2 2m-2 0l2-2" stroke="#ffa726" stroke-width="2" stroke-linecap="round"/>
</svg>''',

    'restart.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
  <path d="M40 24a16 16 0 1 1-5-11.5L40 18" stroke="#ffffff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
  <polyline points="30,18 40,18 40,8" stroke="#ffffff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',

    'network.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
  <circle cx="24" cy="36" r="4" fill="#ffffff"/>
  <path d="M16 28a12 12 0 0 1 16 0" stroke="#ffffff" stroke-width="3" stroke-linecap="round"/>
  <path d="M10 21a20 20 0 0 1 28 0" stroke="#ffffff" stroke-width="3" stroke-linecap="round"/>
  <path d="M4 14a28 28 0 0 1 40 0" stroke="#ffffff" stroke-width="3" stroke-linecap="round"/>
</svg>''',

    'storage.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
  <rect x="6" y="10" width="36" height="28" rx="4" stroke="#ffffff" stroke-width="3"/>
  <line x1="6" y1="28" x2="42" y2="28" stroke="#ffffff" stroke-width="2"/>
  <circle cx="14" cy="33" r="2" fill="#ffffff"/>
  <circle cx="22" cy="33" r="2" fill="#ffffff"/>
  <line x1="30" y1="33" x2="38" y2="33" stroke="#ffffff" stroke-width="2" stroke-linecap="round"/>
</svg>''',

    'sound.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
  <polygon points="12,18 20,18 28,10 28,38 20,30 12,30" stroke="#ffffff" stroke-width="3" stroke-linejoin="round" fill="#ffffff" fill-opacity="0.3"/>
  <path d="M34 16a10 10 0 0 1 0 16" stroke="#ffffff" stroke-width="3" stroke-linecap="round"/>
  <path d="M39 11a18 18 0 0 1 0 26" stroke="#ffffff" stroke-width="3" stroke-linecap="round"/>
</svg>''',

    'sound_mute.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
  <polygon points="12,18 20,18 28,10 28,38 20,30 12,30" stroke="#ffffff" stroke-width="3" stroke-linejoin="round" fill="#ffffff" fill-opacity="0.3"/>
  <line x1="34" y1="18" x2="44" y2="28" stroke="#ff5252" stroke-width="3" stroke-linecap="round"/>
  <line x1="44" y1="18" x2="34" y2="28" stroke="#ff5252" stroke-width="3" stroke-linecap="round"/>
</svg>''',

    'search.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
  <circle cx="20" cy="20" r="12" stroke="#ffffff" stroke-width="3"/>
  <line x1="29" y1="29" x2="41" y2="41" stroke="#ffffff" stroke-width="3" stroke-linecap="round"/>
</svg>''',

    'steam.svg': '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
  <circle cx="24" cy="24" r="21" stroke="#ffffff" stroke-width="2.5" fill="#171a21"/>
  <circle cx="33" cy="17" r="6" stroke="#ffffff" stroke-width="2.5"/>
  <circle cx="19" cy="30" r="4.5" stroke="#ffffff" stroke-width="2.5"/>
  <line x1="20.5" y1="26" x2="28" y2="19" stroke="#ffffff" stroke-width="2.5"/>
</svg>'''
}

out_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'assets', 'icons'))
os.makedirs(out_dir, exist_ok=True)
for name, svg in icons.items():
    p = os.path.join(out_dir, name)
    with open(p, 'w', encoding='utf-8') as f:
        f.write(svg)
    print('Generated', name)

print('All extra icons generated successfully.')
