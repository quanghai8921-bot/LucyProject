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
| `user:watch` | Client to server | `{ "userId": "string" }` | Join the current user's personal notification channel. |
| `notification:watch` | Client to server | `{ "userId": "string" }` | Alias for `user:watch`. |
| `notification:new` | Server to client | Payment notification payload | Sent immediately when someone buys paid content/live or donates to the watched user. |
| `payment:donation` | Server to client | Payment notification payload | Broadcast to a live room when a donation is made in that room. |
