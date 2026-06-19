"""Generate QR PNGs for the VirtuoMate poster. Run once: python generate_assets.py"""
from pathlib import Path

try:
    import qrcode
except ImportError:
    raise SystemExit("Run: pip install qrcode[pil] pillow")

OUT = Path(__file__).parent

# Update these URLs before printing if needed.
DEMO_URL = "https://github.com/"  # Replace with demo video or repo
PDF_URL = "https://github.com/"  # Replace with technical PDF / report link


def make_qr(data: str, name: str) -> None:
    img = qrcode.QRCode(
        version=None,
        error_correction=qrcode.constants.ERROR_CORRECT_M,
        box_size=12,
        border=2,
    )
    img.add_data(data)
    img.make(fit=True)
    path = OUT / name
    img.make_image(fill_color="#EAF0FF", back_color="#09051A").save(path)
    print(f"Wrote {path}")


if __name__ == "__main__":
    make_qr(DEMO_URL, "qr-demo.png")
    make_qr(PDF_URL, "qr-pdf.png")
