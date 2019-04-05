# Node Reputate Protocol

## Summary
This document defines the Node Reputate Protocol, a universial calculation of node reputation based on node discovery and node behaviors in the p2p network.
The reputation of node is used by local node evaluating remote node, it is benefit for local node choosing honest nodes and then communicating wtih them for sync block, broadcast transactions and so no in the future.
Of course, you can implement a custom reputation by yourself,so the Node Reputate Protocol described by this document can be regard as one specific implement.
The current protocol version is 1. 

## Node Reputation
We define node reputation as a `score`.The score is calulated by two steps in turn:
```text
step 1: score += history score * 20% + current score  (if the node is not `Reputation Penalized`)
step 2: score += predefined score
```
`history score` means the last time's reputation of the node.
<br>
`current score` means the this time's reputation of the node.
So we combine the node history behaviors and current behaviors to calculate one node reputation. 

### Reputation Penalized
The node will be penalized if he has malicious behaviors or wrong behaviors.There are 9 situations defined in our protocol.

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

The node's history score will be cleared as zero if the node has any one of situations listed above.

### current score
<b>`current score`</b> is maked up by four types of score:

`1.discovery score` local node sending discovery ping messages's times equals remote node sending discovery pong messages's times, remote node's score increase 101;local node sending findneighbours messages's times equals remote node sending neighbours messages's times, remote node's score increase 10.
<br>

`2.tcp score` successful handshake will let remote node's score increase 10; Total length of tcp data transferring from remote node to local node increase 1 score every 1 data-length unit(10240 bytes),the most increment is 20 scores;local node sending tcp ping messages's times equals remote node sending tcp pong messages's times, remote node's score increase 10. 
<br>

`3.other score` min(1000 / the average time internal(millisecond unit) between sending discovery ping messages and receiving discovery pong messages, 20), it is a score increment.
<br>

`4.diconnect score` remote node disconnect without any reason makes the score decrease 20%(score = score * 80%);the remote node disconnect with reason(one of TOO_MANY_PEERS、TOO_MANY_PEERS_WITH_SAME_IP、DUPLICATE_PEER、TIME_OUT、PING_TIMEOUT、CONNECT_FAIL) makes the score decrease 10%(score = score * 90%)；the local node disconnect with reason(RESET) makes the score decrease 5%(score = score * 95%);the remote node disconnect with reason(REQUESTED) makes the score decrease 30%(score = score * 70%);
if the node disconnect times exceed 20,the score will be cleared as zero, otherwise, it will be decreased pow(2, disconnect times) * 10.