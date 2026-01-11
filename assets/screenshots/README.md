# 📸 Screenshots Guide

## How to Take Screenshots for README

### Required Screenshots (8 total)

1. **feature_banner.png** - Main banner (1200x600px recommended)
2. **splash.png** - Splash screen
3. **search.png** - City search screen
4. **home.png** - Current weather display
5. **hourly.png** - Hourly forecast screen
6. **daily.png** - Daily forecast screen
7. **weekly.png** - Weekly forecast screen
8. **light_theme.png** - App in light mode
9. **dark_theme.png** - App in dark mode (optional, can combine with above)

### Taking Screenshots

#### On Android Emulator:
```bash
# Using ADB
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png ./assets/screenshots/

# Or press: Volume Down + Power button
```

#### On iOS Simulator:
```bash
# Using xcrun
xcrun simctl io booted screenshot ./assets/screenshots/screenshot.png

# Or press: Command + S
```

#### In VS Code:
- Use the Flutter DevTools > Screenshot button

### Creating Feature Banner

Use tools like:
- [Canva](https://canva.com) - Free online design
- [Figma](https://figma.com) - Professional design
- [Photopea](https://photopea.com) - Free Photoshop alternative

Recommended banner specs:
- Size: 1200 x 600 pixels
- Include: App name, tagline, 2-3 phone mockups
- Colors: Match app theme (#5B9EE1, #FFD93D)

### Phone Mockup Tools

- [Mockup World](https://www.mockupworld.co)
- [Facebook Design Resources](https://facebook.design/devices)
- [Screely](https://screely.com) - Browser/device mockups
