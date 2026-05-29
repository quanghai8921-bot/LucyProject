# Lucy Socket Events

This document tracks realtime socket events for the Lucy platform.

## Conventions

- Client-to-server events use `client:*`.
- Server-to-client events use `server:*`.

## Events

| Event | Direction | Payload | Description |
| --- | --- | --- | --- |
| `client:join-room` | Client to server | `{ "roomId": "string" }` | Join a learning room. |
| `server:room-joined` | Server to client | `{ "roomId": "string" }` | Confirm room join. |
