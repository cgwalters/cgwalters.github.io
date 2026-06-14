# cgwalters.github.io

Personal site using Hugo with the PaperMod theme for the blog plus standalone Marp presentations.

## Local Development

### Prerequisites

Install Hugo Extended (0.146.0 or later), Node.js 18+, and `just`:
```bash
# Fedora/RHEL
sudo dnf install hugo just nodejs

# Or download from https://github.com/gohugoio/hugo/releases
```

### Running Locally

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/cgwalters/cgwalters.github.io.git
cd cgwalters.github.io

# Or if already cloned, initialize submodules
git submodule update --init --recursive

# Start the blog locally
hugo server --buildDrafts

# Site will be available at http://localhost:1313
```

To assemble the full GitHub Pages artifact locally, including presentations:

```bash
just build

# Output is written to ./public
```

### Presentations

The `presentations/` directory contains Marp slide decks published at `/presentations/<deck>/`.

`just build` from the repo root is the canonical build command. It runs Hugo first, then renders presentations into `public/presentations/`. CI uses the same command.

#### Working on slides

```bash
cd presentations

# Build one deck into the Pages artifact tree
just build demo

# Or rebuild all decks
just build-all

# Live preview while editing a deck
just preview demo
```

The presentation recipes invoke Marp through `npm exec`, so local development only needs Node.js on your `PATH`; there is no presentation-specific `package.json` or install step.

Decks live at `presentations/<deck>/slides.md` and are published at `/presentations/<deck>/`.

If a deck uses local files, keep them under `presentations/<deck>/assets/`; `just build <deck>` copies that directory into `public/presentations/<deck>/assets/` next to the generated HTML.

Use `just clean` from `presentations/` to remove generated presentation output under `public/presentations/`.

### URL Layout

- `/` is the blog landing page
- `/posts/<slug>/` is the post URL shape
- `/archives/` and `/search/` are the blog utility pages
- `/presentations/<deck>/` is reserved for standalone slide decks

### Creating New Posts

```bash
hugo new content/posts/my-post.md
```

## Deployment

The site automatically deploys to GitHub Pages via GitHub Actions when changes are pushed to the main branch. The deploy workflow runs `just build` and uploads the resulting `public/` directory.
