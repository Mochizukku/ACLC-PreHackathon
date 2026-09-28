// generate_qrcodes.js - Generate QR code image files for registered seller stores
const QRCode = require('qrcode');
const fs = require('fs');
const path = require('path');
const FirebaseDB = require('./firebase_db');

const ASSETS_DIR = path.join(__dirname, '..', 'assets', 'qrcodes');
const ARTIFACTS_DIR = 'C:\\Users\\Administrator\\.gemini\\antigravity\\brain\\80fe0923-afac-45ef-b3c9-a43de8859fc2';

async function generateAllSellerQRCodes() {
  if (!fs.existsSync(ASSETS_DIR)) {
    fs.mkdirSync(ASSETS_DIR, { recursive: true });
  }

  const accounts = await FirebaseDB.getAccounts();
  console.log(`Generating QR Codes for ${accounts.length} seller store accounts...\n`);

  for (const acc of accounts) {
    const storePayload = JSON.stringify({
      type: 'q2_store',
      storeId: acc.id,
      storeName: acc.store_name,
      email: acc.email
    });

    const safeName = acc.store_name.toLowerCase().replace(/[^a-z0-9]/g, '_');
    const assetFilePath = path.join(ASSETS_DIR, `qrcode_${safeName}.png`);
    const artifactFilePath = path.join(ARTIFACTS_DIR, `qrcode_${safeName}.png`);

    // Generate PNG QR Code
    await QRCode.toFile(assetFilePath, storePayload, {
      color: {
        dark: '#111827',
        light: '#FFFFFF'
      },
      width: 512,
      margin: 2
    });

    // Copy to artifacts folder if accessible
    if (fs.existsSync(ARTIFACTS_DIR)) {
      fs.copyFileSync(assetFilePath, artifactFilePath);
    }

    console.log(`✅ Generated QR Code for "${acc.store_name}":`);
    console.log(`   Payload: ${storePayload}`);
    console.log(`   Saved to: ${assetFilePath}\n`);
  }

  console.log('🎉 All seller QR code image files generated successfully!');
}

generateAllSellerQRCodes().catch(err => console.error('Error generating QR Codes:', err));
