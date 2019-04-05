# Node Reputate Protocol

## Summary
This document defines the Node Reputate Protocol, a universial calculation of node reputation based on node discovery and node behaviors in the p2p network.

The current protocol version is 1. You can find a list of changes in past protocol
versions at the end of this document.

## Node Reputation
We define node reputation as a `score`.The score is calulated by two steps in turn:
```text
step 1: score += history score * 20% + current score  (if the node is not `Reputation Penalized`)
step 2: score += predefined score
```
`history score` means the last time's reputation of the node.`current score` means the this time's reputation of the node.So you can learn about that we combine the node
history behaviors and current behaviors to calculate the node reputation. 

### Reputation Penalized
The node will be penalized if he has malicious behaviors or wrong behaviors.There are 9 situations we defined in our protocol.

```text
INCOMPATIBLE_PROTOCOL
BAD_PROTOCOL
BAD_BLOCK
BAD_TX
FORKED
UNLINKABLE
INCOMPATIBLE_CHAIN
SYNC_FAIL
INCOMPATIBLE_VERSION
```

The node's history score will be cleared if the node has any one of situations listed above.

### current score
`current score` is maked up by four types of score:


`discovery score` local node sending discovery ping messages's times equals remote node sending discovery pong messages's times, remote node's score increase 101;local node sending findneighbours messages's times equals remote node sending neighbours messages's times, remote node's score increase 10.
<br>

`tcp score` successful handshake will let remote node's score increase 10; Total length of tcp data transferring from remote node to local node increase 1 score every 1 data-length unit(10240 bytes),the most increment is 20 scores;local node sending tcp ping messages's times equals remote node sending tcp pong messages's times, remote node's score increase 10. 
<br>

`other score` 1000 / the average time internal(millisecond unit) between sending discovery ping messages and receiving discovery pong messages, the most increment is 20.
<br>

`diconnect score` remote node disconnect without any reason makes the score decrease 20%(score = score * 80%);the remote node disconnect with reason(one of TOO_MANY_PEERS、TOO_MANY_PEERS_WITH_SAME_IP、DUPLICATE_PEER、TIME_OUT、PING_TIMEOUT、CONNECT_FAIL) makes the score decrease 10%(score = score * 90%)；the local node disconnect with reason(RESET) makes the score decrease 5%(score = score * 95%);the remote node disconnect with reason(REQUESTED) makes the score decrease 30%(score = score * 70%);
if the node disconnect times exceed 20,the score will be cleared as zero, otherwise, it will be decreased pow(2, disconnect times) * 10.