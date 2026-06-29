# DermaSense web demo on Vercel

The web edition is a static, install-free demonstration. It starts with
simulated pressure and temperature readings, so visitors do not need the
ESP32, its local WiFi network or a backend.

## First deployment

Requirements:

- Flutter available in `PATH`;
- Node.js with `npx`;
- a free Vercel account.

From PowerShell in the project directory, create a preview deployment:

```powershell
.\deploy-vercel.ps1
```

The first run asks you to sign in to Vercel. The script then creates or links
the valid lowercase project name `derma-sense-demo` and accepts the static
project defaults automatically. Vercel prints the preview URL at the end.
Project creation happens only once; later runs reuse the same Vercel project.

After checking that preview URL, publish it as the production deployment:

```powershell
.\deploy-vercel.ps1 -Production
```

To use a different project name, keep it lowercase:

```powershell
.\deploy-vercel.ps1 -ProjectName "my-dermasense-demo"
```

The script always rebuilds Flutter and deploys only `build/web`. It disables
the persistent Flutter PWA cache to prevent an older demo from remaining in a
visitor's browser after a new deployment.

## Manual equivalent

```powershell
flutter pub get
flutter build web --release --pwa-strategy=none
npx vercel@latest deploy build/web
npx vercel@latest deploy build/web --prod
```

The first Vercel command creates a preview. Run the second only after the
preview is correct.

## Important connectivity note

The hosted demo intentionally uses simulation. A public HTTPS page cannot
reliably connect to the ESP32 access point at `ws://192.168.4.1:81`: the
browser may block insecure WebSockets from HTTPS and the device must also be
on the ESP32's private WiFi network. Android and Windows builds remain the
recommended editions for live hardware tests.
