# LChat Setup Instructions

## Quick Fix for "Connection Refused" Error

### Step 1: Find Your Mac's IP Address
Open Terminal and run:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```
Look for something like `inet 192.168.1.100` - this is your Mac's IP address.

### Step 2: Update Network Configuration
1. Open `lib/config/network_config.dart`
2. Replace `192.168.1.100` on line 11 with your actual Mac's IP address

### Step 3: Install and Start the Backend Server
```bash
# Navigate to the server directory
cd server

# Install dependencies
npm install

# Start the server
npm start
```

The server will run on `http://localhost:3000` and `http://0.0.0.0:3000`

### Step 4: Run Your Flutter App
```bash
# In the project root directory
flutter run
```

## Alternative Quick Fix (Temporary)

If you want to test quickly without setting up the full server, you can temporarily change the URLs back to `localhost` and run the app on a physical device connected to the same WiFi network as your Mac.

## Troubleshooting

### If you still get "Connection Refused":

1. **Check if server is running**: Open http://localhost:3000/users in your browser
2. **Verify IP address**: Make sure the IP in `network_config.dart` matches your Mac's IP
3. **Check firewall**: Ensure port 3000 isn't blocked by macOS firewall
4. **Try different approach**: Use `127.0.0.1` instead of `localhost` in some cases

### For Android Emulator:
The app will automatically use `10.0.2.2:3000` which maps to your Mac's localhost.

### For iOS Simulator:
The app will use your Mac's IP address (which you configured in Step 2).

### For Physical Devices:
Both iOS and Android will use your Mac's IP address, so make sure your device and Mac are on the same WiFi network.
