const axios = require('axios');
const { exec } = require('child_process');
const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./sellzivpn.db');

async function renewssh(username, password, exp, limitip, serverId) {
  console.log(`Renewing SSH account for ${username} with expiry ${exp} days, limit IP ${limitip} on server ${serverId}`);

// Validasi username
if (!/^[a-zA-Z0-9-]+$/.test(username)) {
  return '❌ Username tidak valid. Gunakan huruf (A–Z / a–z), angka, dan tanda strip (-) tanpa spasi.';
}


  return new Promise((resolve) => {
    db.get('SELECT * FROM Server WHERE id = ?', [serverId], (err, server) => {
      if (err || !server) {
        console.error('❌ Error fetching server:', err?.message || 'server null');
        return resolve('❌ Server tidak ditemukan. Silakan coba lagi.');
      }

    const domain = server.domain;
    const AUTH_TOKEN = server.auth;

    // Endpoint renew
    const curlCommand = `curl "http://${domain}:5888/renew/zivpn?password=${password}&exp=${exp}&auth=${AUTH_TOKEN}"`;

    exec(curlCommand, (_, stdout) => {
      let d;
      try {
        d = JSON.parse(stdout);
        console.log("⚠️ FULL DATA:", JSON.stringify(d, null, 2));
      } catch (e) {
        console.error('❌ Gagal parsing JSON:', e.message);
        console.error('🪵 Output:', stdout);
        return resolve('❌ Format respon dari server tidak valid.');
      }

      if (d.status !== "success") {
        console.error('❌ Respons error:', d);
        return resolve(`❌ ${d.message}`);
      }

      const msg = `${d.message}

📘 *TUTORIAL PASANG ZIVPN*
📂 Google Drive:
https://drive.google.com/file/d/1BAPWA4ejDsq0IcXxJt72GfjD4224iDpI/view?usp=sharing)

📌 *Langkah Singkat:*
1️⃣ Buka link di atas  
2️⃣ Ikuti panduan di dalam video
3️⃣ Selesai & Connect 🚀  
`;

        return resolve(msg);
      });
    });
  });
}
  
  module.exports = { renewssh };
