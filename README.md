# AuraFit AR

A mobile virtual fitting room for small and medium fashion stores in Sri Lanka. Customers point the phone camera at themselves and see a garment placed on their body in real time. Shop owners manage the catalogue from an admin screen.

Final-year project by D G A S H Premasiri - (ITBIN-2211-0266).

## Features

**Customer**
- Register and log in
- Browse the catalogue by category (Tops, Bottoms, Dresses, Sarees)
- Live try-on: the garment is placed and sized from the body's pose
- Fine-tune the fit by dragging, zooming and changing the garment's opacity
- Switch between the front and back camera
- Save a screenshot of the try-on to the phone's gallery
- Wishlist: add items from the try-on screen, view and remove them in My Wishlist

**Admin (shop owner)**
- Log in
- Add a new clothing item with an image upload
- View and delete items in the catalogue

## How the try-on works

1. The camera sends each frame to Google ML Kit Pose Detection, which runs on the phone (no server round trip). It is built on the BlazePose model family, the same family used by MediaPipe Pose.
2. The model returns 33 body landmarks (shoulders, hips, knees, ankles and more).
3. The app uses the shoulders for the garment's width and position, and the hips, knees or ankles for its length, depending on the garment type.
4. The values are smoothed so the garment does not shake, and the customer can adjust the fit by hand.

Garment images are transparent PNGs. Each category has its own calibration values.

## Tech stack

| Part | Technology |
|---|---|
| Mobile app | Flutter (Dart), camera, google_mlkit_pose_detection, http, image_picker, gal |
| Back end | Node.js, Express, multer, bcryptjs |
| Database | PostgreSQL (tables: clothing_item, category, shop_owner, customer, wishlist) |

The back end is in a separate repository: https://github.com/AshPremas/aurafit_backend.git

## Setup

**Requirements:** Flutter SDK, Node.js, PostgreSQL, and an Android phone with USB debugging turned on.

**1. Database**
- Create a PostgreSQL database named `aurafit_ar` and the five tables listed above.

**2. Back end**
```
cd aurafit_backend
copy .env.example .env      
npm install
node server.js
```
The server runs on port 3000.

**3. App**
```
cd aurafit_ar
flutter pub get
```
- Open `lib/services/api_service.dart` and set `_baseUrl` to the address of your back end.
- With the phone connected by USB, run `adb reverse tcp:3000 tcp:3000` and use `http://localhost:3000/api`.
- Or use your PC's Wi-Fi address (for example `http://192.168.x.x:3000/api`) with the phone on the same network.
- Then run `flutter run`.

## Known limitations

- The try-on is a 2D overlay. There is no cloth movement or 3D fitting.
- Best results need good lighting, a front-facing pose, and the needed body parts in view (hips for tops, ankles for trousers and sarees).
- Calibration was done on a small number of people and one phone.
- The camera preview fills the screen and can look slightly stretched on tall screens.

## Future improvements

- Hash admin passwords and add token-based login for admin actions
- Size recommendation from body measurements
- Side poses and 3D garment fitting
- Testing on more devices and body types