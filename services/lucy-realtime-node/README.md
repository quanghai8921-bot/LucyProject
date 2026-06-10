# Lucy Realtime Node

Owner: Hai

Realtime Socket.IO + Agora token service for live mentor rooms.

## Run

```bash
npm install
npm run dev
```

Required `.env` keys:

```env
PORT=3004
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=...
DB_NAME=lucyProject
AGORA_APP_ID=...
AGORA_APP_CERTIFICATE=...
AGORA_TOKEN_EXPIRES_IN=3600
```

## Socket.IO Events

Connect to `http://localhost:3004`.

### Join Room

Client emits:

```js
socket.emit('room:join', { roomId, userId }, ack)
```

Server updates `RoomParticipants`, joins the socket room, then broadcasts:

- `room:participant-joined`
- `room:participants`

Learners are displayed by `AvatarPersonas.DisplayName`; the room host/mentor is displayed by `Users.FullName`.

### Chat

Client emits:

```js
socket.emit('chat:message', { roomId, userId, text }, ack)
```

Server broadcasts to everyone in the room:

- `chat:message`

### Raise Hand

Client emits:

```js
socket.emit('hand:raise', { roomId, userId, raised: true }, ack)
```

Server updates `RoomParticipants.HandRaiseStatus` and broadcasts:

- `hand:changed`
- `room:participants`

### Mic State

Client emits:

```js
socket.emit('mic:toggle', { roomId, userId, enabled: true }, ack)
```

Server updates `RoomParticipants.MicStatus` and broadcasts:

- `mic:changed`
- `room:participants`

Socket.IO only syncs UI state. Real audio is handled by Agora RTC: each client must join the Agora channel named by `roomId`.

### Leave Room

Client emits:

```js
socket.emit('room:leave', { roomId, userId }, ack)
```

Server updates `RoomParticipants.ParticipantStatus = LEFT` and broadcasts:

- `room:participant-left`
- `room:participants`

## Agora Token

Client calls:

```http
POST /api/realtime/agora/token
Content-Type: application/json

{
  "roomId": "ROOM_ID",
  "userId": "USER_ID"
}
```

Response contains `appId`, `channelName`, `uid`, and `token`. Use `channelName = roomId` and `uid = userId` in the Agora RTC client.
