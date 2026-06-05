require('dotenv').config();

const http = require('http');

const app = require('./app');
const registerSockets = require('./sockets');

const port = process.env.PORT || 3004;
const server = http.createServer(app);

registerSockets(server);

server.listen(port, () => {
  console.log(`Lucy realtime service is running on port ${port}`);
});
