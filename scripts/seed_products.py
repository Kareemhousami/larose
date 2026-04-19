"""
seed_products.py — One-time Firestore seed script for La Rose product catalog.

Usage:
    python scripts/seed_products.py

Requirements:
    - gcloud CLI authenticated (`gcloud auth login`)
    - Python 3.x (stdlib only, no pip packages)

What it does:
    1. Deletes existing products with IDs 101-180
    2. Creates 39 flower-type products (IDs 1001-1039)
    3. Creates 80 event products (IDs 2001-2080)
"""

import json
import os
import subprocess
import urllib.request
import urllib.error
import sys

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

PROJECT_ID = "la-rose-15a8e"
FIRESTORE_BASE = (
    f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}"
    f"/databases/(default)/documents"
)


# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------

def get_access_token() -> str:
    # Allow passing token via environment variable (useful on Windows
    # where gcloud may not be on the subprocess PATH).
    env_token = os.environ.get("GCLOUD_TOKEN")
    if env_token:
        return env_token.strip()
    result = subprocess.run(
        ["gcloud", "auth", "print-access-token"],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


# ---------------------------------------------------------------------------
# Firestore REST helpers
# ---------------------------------------------------------------------------

def firestore_request(method: str, url: str, token: str, body: dict | None = None):
    data = json.dumps(body).encode() if body is not None else None
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        if method == "DELETE" and e.code == 404:
            return None  # already gone — that's fine
        body_text = e.read().decode(errors="replace")
        print(f"  HTTP {e.code} on {method} {url}: {body_text[:300]}", file=sys.stderr)
        raise


def delete_document(doc_id: str, token: str):
    url = f"{FIRESTORE_BASE}/products/{doc_id}"
    firestore_request("DELETE", url, token)


def create_or_update_document(doc_id: str, fields: dict, token: str):
    """PATCH with updateMask creates or fully replaces a document."""
    field_names = list(fields.keys())
    mask_params = "&".join(f"updateMask.fieldPaths={f}" for f in field_names)
    url = f"{FIRESTORE_BASE}/products/{doc_id}?{mask_params}"
    body = {"fields": fields}
    firestore_request("PATCH", url, token)
    # Re-issue without mask to do a full write (simpler than mask bookkeeping)
    url_plain = f"{FIRESTORE_BASE}/products/{doc_id}"
    firestore_request("PATCH", url_plain, token, body)


def write_document(doc_id: str, fields: dict, token: str):
    """Write a Firestore document via PATCH (creates or replaces)."""
    url = f"{FIRESTORE_BASE}/products/{doc_id}"
    body = {"fields": fields}
    firestore_request("PATCH", url, token, body)


# ---------------------------------------------------------------------------
# Firestore value encoding
# ---------------------------------------------------------------------------

def fs_str(v: str) -> dict:
    return {"stringValue": v}


def fs_int(v: int) -> dict:
    return {"integerValue": str(v)}


def fs_bool(v: bool) -> dict:
    return {"booleanValue": v}


def fs_array(items: list) -> dict:
    return {"arrayValue": {"values": items} if items else {"values": []}}


def product_to_fields(p: dict) -> dict:
    return {
        "id":             fs_int(p["id"]),
        "title":          fs_str(p["title"]),
        "description":    fs_str(p["description"]),
        "priceMinor":     fs_int(p["priceMinor"]),
        "inventoryCount": fs_int(p["inventoryCount"]),
        "reservedCount":  fs_int(p["reservedCount"]),
        "flowerType":     fs_str(p["flowerType"]),
        "category":       fs_str(p["category"]),
        "storagePath":    fs_str(p["storagePath"]),
        "thumbnail":      fs_str(p["thumbnail"]),
        "images":         fs_array([]),
        "featured":       fs_bool(p["featured"]),
        "active":         fs_bool(p["active"]),
    }


# ---------------------------------------------------------------------------
# Product data — flower types (IDs 1001-1039)
# ---------------------------------------------------------------------------

# Each entry: (folder_id, display_name, image_filenames, products_list)
# products_list entries: (title, description, priceMinor)

FLOWER_TYPE_PRODUCTS = [
    # ---- hydrangeas (5 images: 1-5) IDs 1001-1005 ----
    ("hydrangeas", "Hydrangeas", ["1.png", "2.png", "3.png", "4.png", "5.png"], [
        ("Blush Hydrangea Bouquet",
         "Soft pink hydrangeas gathered into a lush, full bouquet that radiates gentle romance. Perfect for anniversaries or a heartfelt gift.",
         8500),
        ("Garden Hydrangea Cluster",
         "A generous cluster of garden-fresh hydrangeas in mixed pastels. Brings a cottage-garden feel to any space.",
         7200),
        ("Ivory Hydrangea Bundle",
         "Pure ivory hydrangeas arranged in a classic hand-tied style. Effortlessly elegant for weddings or formal occasions.",
         9800),
        ("Sky Blue Hydrangea Posy",
         "Cool sky-blue hydrangeas in a compact posy that brightens any room with calm, airy color.",
         6400),
        ("Lavender Hydrangea Arrangement",
         "Dreamy lavender hydrangeas massed together for maximum visual impact. A favorite for spa-inspired interiors.",
         7800),
    ]),

    # ---- lilies (5 images: 1-5) IDs 1006-1010 ----
    ("lilies", "Lilies", ["1.png", "2.png", "3.png", "4.png", "5.png"], [
        ("Stargazer Lily Bouquet",
         "Vibrant stargazer lilies with their signature crimson-and-white petals make a bold, fragrant statement. A show-stopping centerpiece.",
         9200),
        ("White Casablanca Lily Bundle",
         "Pristine white Casablanca lilies exude a rich, sweet fragrance. The classic choice for weddings and elegant celebrations.",
         10500),
        ("Peach Asiatic Lily Posy",
         "Warm peach Asiatic lilies in a casual hand-tied posy. Long-lasting blooms that brighten any room for days.",
         6800),
        ("Oriental Lily Mix",
         "A mix of pink and cream oriental lilies, known for their intoxicating perfume and large, showy blooms.",
         8800),
        ("Tiger Lily Accent Bouquet",
         "Striking orange tiger lilies with bold spotted petals. An adventurous bouquet for those who love vibrant color.",
         7500),
    ]),

    # ---- mixed-blooms (5 images: 1-5) IDs 1011-1015 ----
    ("mixed-blooms", "Mixed Blooms", ["1.png", "2.png", "3.png", "4.png", "5.png"], [
        ("Garden Party Mix",
         "A cheerful mix of seasonal blooms in warm sunset tones — perfect for birthdays, thank-yous, or simply brightening someone's day.",
         6200),
        ("Wildflower Medley",
         "An eclectic wildflower bouquet with pops of color from ranunculus, cosmos, and dahlias. Free-spirited and full of character.",
         7400),
        ("Pastel Bloom Collection",
         "Soft pastel blooms including sweet peas, stock, and lisianthus arranged in a romantic, loose style.",
         8100),
        ("Spring Celebration Bouquet",
         "A vibrant spring medley of tulips, daffodils, and freesia that captures the joy of the season.",
         6900),
        ("Seasonal Luxury Mix",
         "An opulent hand-tied arrangement of the season's finest blooms in rich jewel tones. A true luxury gift.",
         10800),
    ]),

    # ---- orchids (5 images: 1-5) IDs 1016-1020 ----
    ("orchids", "Orchids", ["1.png", "2.png", "3.png", "4.png", "5.png"], [
        ("Phalaenopsis Elegance",
         "Graceful white phalaenopsis orchids cascading from a sculptural arrangement. The epitome of timeless luxury.",
         10800),
        ("Purple Dendrobium Spray",
         "Vivid purple dendrobium orchids in a cascading spray. Exotic, long-lasting, and utterly captivating.",
         9500),
        ("Cymbidium Garden Bouquet",
         "Bold cymbidium orchids in soft green and cream tones, artfully arranged for a modern, architectural look.",
         10200),
        ("Pink Mokara Cluster",
         "Tropical pink mokara orchids clustered together for a vibrant, tropical-inspired statement.",
         8900),
        ("Vanilla Orchid Accent",
         "Delicate cream-colored orchids with a warm vanilla hue, perfect for adding a refined accent to any décor.",
         9100),
    ]),

    # ---- peonies (5 images: 1-5) IDs 1021-1025 ----
    ("peonies", "Peonies", ["1.png", "2.png", "3.png", "4.png", "5.png"], [
        ("Blush Peony Garden Bouquet",
         "Lush blush peonies at their most open, bursting with ruffled layers of petals. Irresistibly romantic and full of fragrance.",
         10500),
        ("Coral Peony Posy",
         "Vibrant coral peonies gathered in a generous hand-tied posy. Warm, joyful, and luxuriously full.",
         9800),
        ("White Peony Bridal Bundle",
         "Crisp white peonies arranged in a classic bridal style. Pure, pristine, and breathtakingly elegant.",
         11000),
        ("Pink Peony Cloud",
         "Soft pink peonies massed together in a dreamy cloud of petals. A romantic gift for any occasion.",
         9200),
        ("Deep Rose Peony Arrangement",
         "Deep rose-red peonies with velvety petals that deepen in color toward the center. Rich and utterly sophisticated.",
         10000),
    ]),

    # ---- roses (5 images: 1-5) IDs 1026-1030 ----
    ("roses", "Roses", ["1.png", "2.png", "3.png", "4.png", "5.png"], [
        ("Classic Red Rose Dozen",
         "A timeless dozen of long-stemmed red roses, the universal symbol of love and passion. Elegantly wrapped and ready to impress.",
         9900),
        ("Pink Garden Rose Bouquet",
         "Garden roses in soft pink tones, fuller and more fragrant than standard roses. A romantic and luxurious choice.",
         8700),
        ("Blush & Ivory Rose Mix",
         "A sophisticated mix of blush and ivory roses in a loose, garden-inspired arrangement. Perfect for weddings or elegant celebrations.",
         10200),
        ("Yellow Rose Sunshine Bundle",
         "Bright yellow roses that radiate warmth and friendship. A cheerful bouquet for congratulations or thank-yous.",
         7600),
        ("Lavender Rose Whimsy",
         "Rare lavender roses with a soft, dreamy hue. These enchanting blooms make an unforgettable and distinctive gift.",
         10500),
    ]),

    # ---- sunflowers (5 images: 1-5) IDs 1031-1035 ----
    ("sunflowers", "Sunflowers", ["1.png", "2.png", "3.png", "4.png", "5.png"], [
        ("Classic Sunflower Bunch",
         "Tall, golden sunflowers gathered into a cheerful, rustic bunch. Brings instant warmth and happiness to any space.",
         6500),
        ("Sunflower & Daisy Mix",
         "Sunflowers paired with white daisies for a bright, country-garden charm. A delightful gift for any occasion.",
         7200),
        ("Mini Sunflower Posy",
         "Petite sunflowers in a compact, sweet posy that packs a big punch of sunshine in a small package.",
         5800),
        ("Sunflower Harvest Arrangement",
         "Golden sunflowers mixed with autumnal accents for a warm, harvest-season bouquet full of natural beauty.",
         7800),
        ("Sunflower Luxury Bundle",
         "Giant-headed sunflowers with velvety petals in a lush, generous bundle. Bold, beautiful, and totally unforgettable.",
         9000),
    ]),

    # ---- tulips (4 images: 1, 3, 4, 5 — NO 2.png) IDs 1036-1039 ----
    ("tulips", "Tulips", ["1.png", "3.png", "4.png", "5.png"], [
        ("Spring Tulip Bouquet",
         "Fresh spring tulips in vibrant mixed colors — the quintessential symbol of the season. Uplifting and endlessly cheerful.",
         6800),
        ("White Tulip Elegance",
         "Pure white tulips in a classic hand-tied arrangement. Simple, sophisticated, and effortlessly beautiful.",
         7500),
        ("Purple & Pink Tulip Mix",
         "Rich purple and soft pink tulips together in a striking two-tone bouquet. Modern, chic, and full of personality.",
         7900),
        ("Parrot Tulip Fantasy",
         "Exotic parrot tulips with frilled, multicolored petals in a wildly expressive arrangement. For those who dare to be different.",
         8600),
    ]),
]


def build_flower_type_products() -> list[dict]:
    products = []
    current_id = 1001

    for folder_id, display_name, filenames, entries in FLOWER_TYPE_PRODUCTS:
        for i, (title, description, price_minor) in enumerate(entries):
            filename = filenames[i]
            products.append({
                "id": current_id,
                "title": title,
                "description": description,
                "priceMinor": price_minor,
                "inventoryCount": 20,
                "reservedCount": 0,
                "flowerType": display_name,
                "category": "",
                "storagePath": f"flower_types/{folder_id}/{filename}",
                "thumbnail": "",
                "images": [],
                "featured": i == 0,
                "active": True,
            })
            current_id += 1

    return products


# ---------------------------------------------------------------------------
# Product data — event products (IDs 2001-2080)
# ---------------------------------------------------------------------------

VARIATIONS = [
    ("01", "round",                    "Round"),
    ("02", "loose-garden",             "Loose Garden"),
    ("03", "asymmetrical",             "Asymmetrical"),
    ("04", "compact-dome",             "Compact Dome"),
    ("05", "tall-hand-tied",           "Tall Hand Tied"),
    ("06", "crescent",                 "Crescent"),
    ("07", "oval",                     "Oval"),
    ("08", "editorial-loose",          "Editorial Loose"),
    ("09", "structured-asymmetrical",  "Structured Asymmetrical"),
    ("10", "rounded-luxury-cloud",     "Rounded Luxury Cloud"),
]

# Events: (event_id, display_name, price_range_minor_per_variation)
# price_range_minor_per_variation: list of 10 prices, one per variation
EVENTS = [
    ("anniversary", "Anniversary", [
        8800, 9200, 8500, 9600, 9900, 8700, 9100, 10200, 9500, 10500,
    ]),
    ("birthday", "Birthday", [
        5200, 5800, 5500, 6000, 6400, 5300, 5700, 6600, 6200, 6800,
    ]),
    ("congratulations", "Congratulations", [
        6500, 7000, 6800, 7200, 7600, 6700, 7100, 7800, 7400, 8000,
    ]),
    ("graduation", "Graduation", [
        6200, 6700, 6500, 6900, 7300, 6400, 6800, 7500, 7100, 7700,
    ]),
    ("new-baby", "New Baby", [
        6000, 6400, 6200, 6700, 7000, 6100, 6500, 7200, 6900, 7400,
    ]),
    ("romantic", "Romantic", [
        7500, 8000, 7800, 8400, 8800, 7700, 8200, 9200, 8600, 9600,
    ]),
    ("sympathy", "Sympathy", [
        7200, 7700, 7400, 7900, 8300, 7300, 7800, 8600, 8100, 8900,
    ]),
    ("wedding", "Wedding", [
        8900, 9400, 9100, 9800, 10200, 9200, 9600, 10500, 10000, 11000,
    ]),
]

# Per-event, per-variation descriptions
# Keys: (event_id, variation_style_slug)
DESCRIPTIONS: dict[tuple[str, str], str] = {
    # ---- anniversary ----
    ("anniversary", "round"): "A classic round bouquet of lush blooms celebrating years of love. Timeless and beautifully balanced.",
    ("anniversary", "loose-garden"): "A free-spirited loose garden arrangement that reflects the natural beauty of a lasting relationship.",
    ("anniversary", "asymmetrical"): "An artfully asymmetrical bouquet that brings modern elegance to an anniversary celebration.",
    ("anniversary", "compact-dome"): "A dense, dome-shaped bouquet packed with premium blooms — an intimate token of enduring love.",
    ("anniversary", "tall-hand-tied"): "A tall, dramatic hand-tied bouquet that makes a grand romantic gesture for a milestone anniversary.",
    ("anniversary", "crescent"): "A graceful crescent-shaped bouquet that curves with the elegance of a long and cherished partnership.",
    ("anniversary", "oval"): "A soft oval bouquet in romantic hues, perfect for marking another beautiful year together.",
    ("anniversary", "editorial-loose"): "An editorial-inspired loose arrangement that brings contemporary artistry to your anniversary.",
    ("anniversary", "structured-asymmetrical"): "A structured yet asymmetrical bouquet that balances tradition with a modern romantic touch.",
    ("anniversary", "rounded-luxury-cloud"): "A lavish cloud of the finest blooms creating a dreamy, rounded luxury bouquet for a special anniversary.",

    # ---- birthday ----
    ("birthday", "round"): "A cheerful round bouquet bursting with colour — the perfect birthday surprise for someone special.",
    ("birthday", "loose-garden"): "A loose, garden-fresh arrangement that feels like gathering wildflowers on a bright birthday morning.",
    ("birthday", "asymmetrical"): "A playful asymmetrical bouquet in vibrant birthday tones that's as unique as the person receiving it.",
    ("birthday", "compact-dome"): "A neat, compact dome of colourful blooms — a delightful birthday gift that fits any space.",
    ("birthday", "tall-hand-tied"): "A tall, showstopping hand-tied bouquet to mark a birthday in the most memorable way.",
    ("birthday", "crescent"): "A crescent bouquet in bright, festive colours that curves with joy and birthday cheer.",
    ("birthday", "oval"): "A cheerful oval bouquet filled with seasonal birthday blooms to brighten someone's special day.",
    ("birthday", "editorial-loose"): "An editorial-style loose bouquet with bold colour choices that make a striking birthday statement.",
    ("birthday", "structured-asymmetrical"): "A structured asymmetrical birthday bouquet with a modern twist on classic celebration flowers.",
    ("birthday", "rounded-luxury-cloud"): "A lavish cloud bouquet overflowing with premium blooms — the ultimate birthday indulgence.",

    # ---- congratulations ----
    ("congratulations", "round"): "A vibrant round bouquet that shouts congratulations loud and proud with every petal.",
    ("congratulations", "loose-garden"): "A free and celebratory loose garden bouquet for marking a wonderful achievement.",
    ("congratulations", "asymmetrical"): "An asymmetrical arrangement that reflects the exciting, dynamic energy of a big congratulations.",
    ("congratulations", "compact-dome"): "A compact dome of bright, celebratory blooms — a tangible symbol of pride and joy.",
    ("congratulations", "tall-hand-tied"): "A tall hand-tied bouquet in bold, uplifting colours to celebrate an impressive milestone.",
    ("congratulations", "crescent"): "A graceful crescent bouquet in vivid tones — congratulations delivered with elegance and flair.",
    ("congratulations", "oval"): "A generous oval bouquet brimming with congratulatory colour and good cheer.",
    ("congratulations", "editorial-loose"): "An editorial-loose arrangement that turns a congratulations moment into an art statement.",
    ("congratulations", "structured-asymmetrical"): "A bold, structured asymmetrical bouquet for celebrating achievements that stand out from the crowd.",
    ("congratulations", "rounded-luxury-cloud"): "A luxurious cloud of premium blooms — the grandest possible way to say congratulations.",

    # ---- graduation ----
    ("graduation", "round"): "A polished round bouquet in school-proud colours to honour a hard-earned graduation day.",
    ("graduation", "loose-garden"): "A loosely arranged garden bouquet that captures the fresh start and freedom of graduation.",
    ("graduation", "asymmetrical"): "An asymmetrical graduation bouquet with modern flair — for a graduate who forges their own path.",
    ("graduation", "compact-dome"): "A tidy, compact dome bouquet — a refined and proud gift for a graduation milestone.",
    ("graduation", "tall-hand-tied"): "A tall, striking hand-tied bouquet to celebrate the graduate's towering achievement.",
    ("graduation", "crescent"): "A crescent graduation bouquet that arcs toward the bright future that awaits.",
    ("graduation", "oval"): "A classic oval bouquet in celebration colours, perfect for congratulating a new graduate.",
    ("graduation", "editorial-loose"): "An editorial-inspired loose bouquet for the creative graduate who sees the world differently.",
    ("graduation", "structured-asymmetrical"): "A structured, asymmetrical bouquet that balances ambition and artistry — ideal for a standout graduate.",
    ("graduation", "rounded-luxury-cloud"): "A sumptuous cloud bouquet to honour a graduation achievement worthy of the finest flowers.",

    # ---- new-baby ----
    ("new-baby", "round"): "A soft, round bouquet in tender pastels to welcome a precious new arrival into the world.",
    ("new-baby", "loose-garden"): "A gentle loose garden arrangement in baby-soft tones celebrating the miracle of new life.",
    ("new-baby", "asymmetrical"): "A sweet asymmetrical bouquet in delicate hues, as endearingly unique as the new baby.",
    ("new-baby", "compact-dome"): "A neat pastel dome bouquet — a delicate and heartfelt gift for a new parent.",
    ("new-baby", "tall-hand-tied"): "A tall, graceful hand-tied bouquet in soft colours to celebrate the arrival of a new baby.",
    ("new-baby", "crescent"): "A gentle crescent bouquet cradling soft blooms — as nurturing and tender as a parent's embrace.",
    ("new-baby", "oval"): "A pretty oval bouquet in the softest shades, a lovely welcome for a newborn.",
    ("new-baby", "editorial-loose"): "An editorial loose arrangement in dreamy pastels to mark the start of a beautiful new chapter.",
    ("new-baby", "structured-asymmetrical"): "A softly structured asymmetrical bouquet in pale, peaceful tones for the newest member of the family.",
    ("new-baby", "rounded-luxury-cloud"): "A pillowy cloud of the softest blooms — a luxurious celebration of a beautiful new life.",

    # ---- romantic ----
    ("romantic", "round"): "A lushly romantic round bouquet of deep reds and blush petals, made to melt hearts.",
    ("romantic", "loose-garden"): "A loose, effortlessly romantic garden arrangement that whispers love with every bloom.",
    ("romantic", "asymmetrical"): "An asymmetrical romantic bouquet with a passionate, free-spirited arrangement that mirrors true love.",
    ("romantic", "compact-dome"): "A compact dome of the most romantic blooms — intimate, heartfelt, and deeply expressive.",
    ("romantic", "tall-hand-tied"): "A tall, sweeping hand-tied bouquet in romantic hues that makes an unforgettable declaration of love.",
    ("romantic", "crescent"): "A crescent bouquet that curves with desire — sculptural, sensual, and thoroughly romantic.",
    ("romantic", "oval"): "A soft oval bouquet in blush and wine tones — a tender and romantic gesture for someone special.",
    ("romantic", "editorial-loose"): "An editorial-loose romantic arrangement with avant-garde styling for a love that's anything but ordinary.",
    ("romantic", "structured-asymmetrical"): "A structured asymmetrical bouquet of romantic blooms — passion expressed through artful design.",
    ("romantic", "rounded-luxury-cloud"): "A cloud of the most exquisite romantic blooms — the ultimate luxury statement of love.",

    # ---- sympathy ----
    ("sympathy", "round"): "A serene round bouquet in soft, muted tones — a gentle expression of sympathy and care.",
    ("sympathy", "loose-garden"): "A quietly beautiful loose garden arrangement to offer comfort and peace during a difficult time.",
    ("sympathy", "asymmetrical"): "A softly asymmetrical sympathy bouquet arranged with quiet dignity and heartfelt compassion.",
    ("sympathy", "compact-dome"): "A compact, peaceful dome of white and cream blooms — a sincere and respectful sympathy tribute.",
    ("sympathy", "tall-hand-tied"): "A tall, graceful hand-tied bouquet in soothing tones to express sincere condolences.",
    ("sympathy", "crescent"): "A gentle crescent sympathy bouquet in peaceful white and sage, offering quiet solace.",
    ("sympathy", "oval"): "A calm oval bouquet in soft neutrals — a dignified and heartfelt expression of sympathy.",
    ("sympathy", "editorial-loose"): "An editorial-loose sympathy arrangement with thoughtful, understated beauty that honours a life well lived.",
    ("sympathy", "structured-asymmetrical"): "A structured asymmetrical tribute that balances grace and solemnity in a time of loss.",
    ("sympathy", "rounded-luxury-cloud"): "A generous cloud of white and soft blooms — a lavish and deeply heartfelt sympathy tribute.",

    # ---- wedding ----
    ("wedding", "round"): "A quintessential bridal bouquet — lush, round, and overflowing with the finest white and blush blooms.",
    ("wedding", "loose-garden"): "A romantic loose garden bridal bouquet that feels like it was gathered from a dreamy English garden.",
    ("wedding", "asymmetrical"): "A modern asymmetrical wedding bouquet with an effortlessly artistic and fashion-forward aesthetic.",
    ("wedding", "compact-dome"): "A perfectly compact dome bridal bouquet — elegant, structured, and absolutely timeless.",
    ("wedding", "tall-hand-tied"): "A tall, cascading hand-tied bridal bouquet for a bride who wants to make an unforgettable entrance.",
    ("wedding", "crescent"): "A graceful crescent wedding bouquet with a classic cascading silhouette beloved by brides for decades.",
    ("wedding", "oval"): "A refined oval bridal bouquet in white and ivory, the picture of understated wedding elegance.",
    ("wedding", "editorial-loose"): "An editorial-loose bridal bouquet with an avant-garde sensibility for the fashion-forward modern bride.",
    ("wedding", "structured-asymmetrical"): "A structured asymmetrical wedding bouquet that pairs architectural precision with natural beauty.",
    ("wedding", "rounded-luxury-cloud"): "A breathtaking cloud of the most luxurious wedding blooms — the bouquet every bride dreams of.",
}


def build_event_products() -> list[dict]:
    products = []
    current_id = 2001

    for event_id, display_name, prices in EVENTS:
        for i, (var_num, style_slug, style_display) in enumerate(VARIATIONS):
            filename = f"variation-{var_num}-{style_slug}.png"
            title = f"{display_name} {style_display} Bouquet"
            description = DESCRIPTIONS[(event_id, style_slug)]
            products.append({
                "id": current_id,
                "title": title,
                "description": description,
                "priceMinor": prices[i],
                "inventoryCount": 15,
                "reservedCount": 0,
                "flowerType": "",
                "category": display_name,
                "storagePath": f"events/{event_id}/bouquets/{filename}",
                "thumbnail": "",
                "images": [],
                "featured": i == 0,
                "active": True,
            })
            current_id += 1

    return products


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    print("La Rose — Firestore product seed script")
    print("=" * 50)

    # Auth
    print("\nObtaining access token from gcloud…")
    try:
        token = get_access_token()
    except subprocess.CalledProcessError as e:
        print("ERROR: Could not obtain access token. Is gcloud authenticated?", file=sys.stderr)
        print(e.stderr, file=sys.stderr)
        sys.exit(1)
    print("  Token obtained.")

    # --- Step 1: Delete legacy products (IDs 101-180) ---
    print("\nStep 1: Deleting legacy products (IDs 101-180)…")
    deleted = 0
    for doc_id in range(101, 181):
        print(f"  Deleting product {doc_id}…", end=" ", flush=True)
        delete_document(str(doc_id), token)
        print("done")
        deleted += 1
    print(f"  {deleted} documents deleted (or were already gone).")

    # --- Step 2: Create flower-type products (IDs 1001-1039) ---
    flower_products = build_flower_type_products()
    print(f"\nStep 2: Creating {len(flower_products)} flower-type products (IDs 1001-1039)…")
    for p in flower_products:
        print(f"  Writing product {p['id']}: {p['title']}…", end=" ", flush=True)
        fields = product_to_fields(p)
        write_document(str(p["id"]), fields, token)
        print("done")
    print(f"  {len(flower_products)} flower-type products created.")

    # --- Step 3: Create event products (IDs 2001-2080) ---
    event_products = build_event_products()
    print(f"\nStep 3: Creating {len(event_products)} event products (IDs 2001-2080)…")
    for p in event_products:
        print(f"  Writing product {p['id']}: {p['title']}…", end=" ", flush=True)
        fields = product_to_fields(p)
        write_document(str(p["id"]), fields, token)
        print("done")
    print(f"  {len(event_products)} event products created.")

    # Summary
    print("\n" + "=" * 50)
    print("Seed complete.")
    print(f"  Legacy products deleted : {deleted}")
    print(f"  Flower-type products    : {len(flower_products)} (IDs 1001–{1000 + len(flower_products)})")
    print(f"  Event products          : {len(event_products)} (IDs 2001–{2000 + len(event_products)})")
    print("  Total new products      :", len(flower_products) + len(event_products))


if __name__ == "__main__":
    main()
