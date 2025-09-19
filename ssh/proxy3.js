/*
 * Proxy Bridge (Cleaner Version)
 * Original Author: PANCHO7532 - P7COMUnications LLC (c) 2021
 * Modified by givps (2025)
 */

const net = require("net");

// Default Config
let dhost = "127.0.0.1";
let dport = null;
let mainPort = null;
let packetsToSkip = 0;
let gcwarn = true;

// Parse CLI Args
for (let c = 0; c < process.argv.length; c++) {
  switch (process.argv[c]) {
    case "-skip":
      packetsToSkip = parseInt(process.argv[c + 1], 10) || 0;
      break;
    case "-dhost":
      dhost = process.argv[c + 1];
      break;
    case "-dport":
      dport = parseInt(process.argv[c + 1], 10);
      break;
    case "-mport":
      mainPort = parseInt(process.argv[c + 1], 10);
      break;
  }
}

// Validate args
if (!dport || !mainPort) {
  console.error("[ERROR] Missing required arguments: -dport and -mport");
  process.exit(1);
}

// Garbage collector
function gcollector() {
  if (global.gc) {
    global.gc();
  } else if (gcwarn) {
    console.warn("[WARN] Garbage Collector not enabled! Start node with --expose-gc");
    gcwarn = false;
  }
}
setInterval(gcollector, 10000); // setiap 10 detik saja, biar tidak spam

// Proxy Server
const server = net.createServer((socket) => {
  let packetCount = 0;

  console.log(`[INFO] Connection from ${socket.remoteAddress}:${socket.remotePort}`);

  // Write handshake (fake HTTP upgrade)
  socket.write(
    "HTTP/1.1 101 Switching Protocols\r\nContent-Length: 1048576000000\r\n\r\n",
    (err) => {
      if (err) console.error("[ERROR] Failed handshake:", err.message);
    }
  );

  // Connect to remote host
  const conn = net.createConnection({ host: dhost, port: dport });

  // Data from client → remote
  socket.on("data", (data) => {
    if (packetCount < packetsToSkip) {
      packetCount++;
      return;
    }
    conn.write(data, (err) => {
      if (err) console.error("[EWRITE] Failed client→remote:", err.message);
    });
  });

  // Data from remote → client
  conn.on("data", (data) => {
    socket.write(data, (err) => {
      if (err) console.error("[EWRITE] Failed remote→client:", err.message);
    });
  });

  // Error handling
  socket.on("error", (err) => {
    console.error(`[SOCKET] ${err.message} from ${socket.remoteAddress}:${socket.remotePort}`);
    conn.destroy();
  });
  conn.on("error", (err) => {
    console.error("[REMOTE] " + err.message);
    socket.destroy();
  });

  // Cleanup on close
  socket.on("close", () => {
    console.log(`[INFO] Client disconnected ${socket.remoteAddress}:${socket.remotePort}`);
    conn.destroy();
  });
  conn.on("close", () => {
    socket.destroy();
  });
});

// Server events
server.on("error", (err) => {
  console.error("[SRV] Error:", err.message);
});

server.listen(mainPort, () => {
  console.log(`[INFO] Proxy listening on port ${mainPort}`);
  console.log(`[INFO] Redirecting traffic to ${dhost}:${dport}`);
});
