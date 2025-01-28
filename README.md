# Samsung Android Debloat & Optimization Scripts

Scripts to debloat and optimize Samsung Android devices.

⚠️ **WARNING**: Use at your own risk. Back up your device before making any changes.

## Requirements

- A bash-compatible shell
- ADB (Android Debug Bridge) installed
- USB debugging enabled on your device

## Usage

Make the scripts executable:
```bash
chmod +x debloat.sh tweaks.sh
```

### Debloat Script

Three levels of app removal:
```bash
./debloat.sh light   # Basic removal of non-essential apps
./debloat.sh medium  # Light + additional Samsung and Google apps
./debloat.sh heavy   # Most aggressive removal of system apps
```

### Optimization Script

```bash
# Run with default settings
./tweaks.sh

# Available options:
./tweaks.sh [-a SCALE] [-b] [-l] [-p] [-g]

Options:
  -a SCALE     Set animation scale (default: 0.35)
  -b           Skip battery optimizations
  -l           Skip location optimizations
  -p           Skip performance optimizations
  -g           Skip Game Optimizing Service (GOS) disable
```

## License

MIT License