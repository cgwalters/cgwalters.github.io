# cgwalters.github.io

Personal blog using Hugo with the PaperMod theme.

## Local Development

### Prerequisites

Install Hugo Extended (0.138.0 or later):
```bash
# Fedora/RHEL
sudo dnf install hugo

# Or download from https://github.com/gohugoio/hugo/releases
```

### Running Locally

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/cgwalters/cgwalters.github.io.git
cd cgwalters.github.io

# Or if already cloned, initialize submodules
git submodule update --init --recursive

# Start local server
hugo server --buildDrafts

# Site will be available at http://localhost:1313
```

### Creating New Posts

```bash
hugo new content/posts/my-post.md
```

## Deployment

The site automatically deploys to GitHub Pages via GitHub Actions when changes are pushed to the main branch.
