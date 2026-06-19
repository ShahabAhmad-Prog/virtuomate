# VirtuoMate Open House Poster (24 × 60 in)

## Files

| File | Purpose |
|------|---------|
| `virtuomate-poster-24x60.html` | **Print-ready poster** (open in Chrome/Edge) |
| `generate_assets.py` | Optional local QR PNGs (requires Python + `qrcode`) |

## Print to PDF (recommended)

1. Open **`virtuomate-poster-24x60.html`** in **Google Chrome** or **Microsoft Edge** (double-click or drag into browser).
2. Wait a few seconds so **QR images** load (needs internet once).
3. Press **Ctrl+P** → **Save as PDF**.
4. Set:
   - **Paper size:** Custom **24 × 60 inches** (or enter width 24 in, height 60 in).
   - **Margins:** **None**
   - **Scale:** **100%** (do not use “Fit to page”).
   - **Background graphics:** **On**
5. Save as `VirtuoMate-Poster-24x60.pdf`.
6. Send PDF to your print shop (foam board / vinyl / fabric banner).

## Send to print shop

- **Size:** 24 in (W) × 60 in (H)
- **Resolution:** PDF vector text + 300 DPI if they rasterize
- **Finish:** Matte or satin (reduces glare under hall lights)

## Before you print — customize

Edit `virtuomate-poster-24x60.html` in any text editor:

1. **QR codes** — Search for `api.qrserver.com` and replace the `data=` URL:
   - Top QR: your email or contact page
   - Bottom QR: demo video, GitHub repo, or hosted app link
2. **Open House label** — Search `FoIT Open House` and set your semester/year.
3. **Real app screenshots** (optional) — Replace a `.phone` block with:
   ```html
   <img src="dashboard.png" style="width:9.2in;height:16.5in;object-fit:cover;border-radius:0.45in" alt="" />
   ```
   Export PNGs from Android emulator or `flutter run` screenshots.

## Optional: local QR images

If you have Python:

```powershell
cd "d:\Virtomate Project\poster"
pip install qrcode pillow
python generate_assets.py
```

Then in the HTML, replace QR `<img src="https://api.qrserver.com/...">` with `<img src="qr-demo.png" />`.

## Design notes

- Layout follows the **24×60 banner** plan: hero → large phone → two supporting phones → pillars → architecture → team → QR.
- Colors match the VirtuoMate app theme (`#09051A`, `#3BE7FF`, `#8B5CFF`).
