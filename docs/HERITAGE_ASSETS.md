# ViePN Widget+ — Heritage Art Kit

Source: single JPG sprite sheet supplied in this conversation by the user, resolution 1448 × 1086.

Derived artworks: 6 illustrated calendar panels (JPEG), 4 status badges (transparent PNG), 7 decorative illustrations (transparent PNG).

Implementation: `Shared/Lunar/Assets.xcassets`, `LunarHeritageArt.swift`, `LunarArtwork` in `LunarAppearance.swift`. Both iOS app and Widget Extension use the same assets. Existing saved themes decode with `artwork = automatic` if the field is missing.

Default Minimal Zen remains clean and unillustrated; Heritage, Tết, Dark and Mid-Autumn themes use curated scenes, and users can choose a different background or no image.

The source was a JPG collage rather than separate native transparent layers. Cutouts may contain JPEG edge artifacts; preserving readability takes priority over full-bleed ornamentation.

Attribution/IP: artwork supplied by the user. Confirm copyright/license for App Store distribution.
