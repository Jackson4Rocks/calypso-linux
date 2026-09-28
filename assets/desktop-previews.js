(() => {
  const hypr = document.querySelector('[data-hypr-preview]');
  if (!hypr) return;

  const parts = [
    './assets/hyprland-presentation/part0.b64',
    './assets/hyprland-presentation/part1.b64'
  ];

  Promise.all(parts.map((url) => fetch(url, { cache: 'force-cache' }).then((r) => {
    if (!r.ok) throw new Error(`Failed to load ${url}`);
    return r.text();
  })))
    .then((chunks) => {
      const base64 = chunks.join('');
      const binary = atob(base64);
      const bytes = new Uint8Array(binary.length);

      for (let i = 0; i < binary.length; i++) {
        bytes[i] = binary.charCodeAt(i);
      }

      const blobUrl = URL.createObjectURL(new Blob([bytes], { type: 'image/webp' }));
      hypr.src = blobUrl;
      hypr.addEventListener('load', () => URL.revokeObjectURL(blobUrl), { once: true });
    })
    .catch((error) => {
      console.warn('Calypso Hyprland preview fallback:', error);
    });
})();
