# Node Discovery Protocol

## Summary
This document defines the Node Discovery protocol, a Kademlia-like DHT that
stores information about Tron nodes. We recommand the Kademlia structure because it is
an efficient way to organize a distributed index of nodes and yields a topology of low
diameter.

The current protocol version is 1. You can find a list of changes in past protocol
versions at the end of this document.

## Kademlia Parameter
```text
ALPHA = 3
BUCKET_SIZE = 16 
MAX_STEPS = 8
BINS = 256
```

## Node Identities

Every node has a cryptographic identity, a key on the elliptic curve secp256k1. The public
key of the node serves as its identifier or 'node ID', the node ID has 256 bits or 32 bytes.

The 'distance' between two node is determined by their node IDs.

```text
n1 = node ID of node1
n2 = node ID of node2
value = n1 XOR n2
distance(node1, node2) = Kademlia.BINS - count(leading bit=0 of value).
```

## Node Table

Nodes in the Discovery Protocol keep information about other nodes in their neighborhood.
Neighbor nodes are stored in a routing table consisting of 'k-buckets'. For each `0 ≤ i <
256`, every node keeps a k-bucket for nodes of distance between `2i` and `2i+1` from
itself.

The Node Discovery Protocol uses `k = 16`, i.e. every k-bucket contains up to 16 node
entries. The entries are sorted by time last seen — least-recently seen node at the head,
most-recently seen at the tail.

Whenever a new node N₁ is encountered, it can be inserted into the corresponding bucket.
If the bucket contains less than `k` entries N₁ can simply be added as the first entry. If
the bucket already contains `k` entries, the least recently seen node in the bucket, N₂,
needs to be revalidated by sending a ping packet. If no reply is received from N₂ it is
considered dead, removed and N₁ added to the front of the bucket.

## Endpoint Proof

To prevent traffic amplification attacks, implementations must verify that the sender of a
query participates in the discovery protocol. 

## Recursive Discover

A 'discover' locates the `k` closest nodes to a node ID.

The discover initiator starts by picking `Kademlia.ALPHA` closest nodes to the target it knows of. 
The initiator then sends concurrent [FindNeighbours] messages to those nodes. 
The recursive step, the initiator resends FindNeighbours to nodes it has learned about from previous queries. 
Of the `k` nodes the initiator has heard of closest to the target, it picks `Kademlia.ALPHA` that it has not yet queried and resends [FindNode]
to them. Nodes that fail to respond quickly are removed from consideration until and
unless they do respond.

If a round of FindNode queries fails to return a node any closer than the closest already
seen, the initiator resends the find node to all of the `k` closest nodes it has not
already queried. The lookup terminates when the initiator has queried and gotten responses
from the `k` closest nodes it has seen.

### Ping Message (0x01)

```text
message PingMessage {
  Endpoint from = 1;
  Endpoint to = 2;
  int32 version = 3;
  int64 timestamp = 4;
}
```

The timestamp field is an absolute UNIX time stamp. Packets containing a time stamp
that lies in the past are expired may not be processed.

When a ping message is received, the recipient should reply with a [Pong] message. It may
also consider the sender for addition into the node table. Implementations should ignore
any mismatches in version.

If no communication with the sender has occurred within the last 12h, a ping should be
sent in addition to pong in order to receive an endpoint proof.

### Pong Message (0x02)

```text
message PongMessage {
  Endpoint from = 1;
  int32 echo = 2;
  int64 timestamp = 3;
}
```

Pong is the reply to ping.

`ping-hash` should be equal to `hash` of the corresponding ping packet. Implementations
should ignore unsolicited pong packets that do not contain the hash of the most recent
ping packet.

### FindNeighbours Message (0x03)

```text
message FindNeighbours {
  Endpoint from = 1;
  bytes targetId = 2;
  int64 timestamp = 3;
}

```

A FindNeighbours message requests information about nodes close to `target`. The `target` is a
64-byte secp256k1 public key. When FindNeighbours message is received, the recipient should reply with
[Neighbors] message containing the closest 16 nodes to target found in its local table.

To guard against traffic amplification attacks, Neighbors replies should only be sent if
the sender of FindNeighbours has been verified by the endpoint proof procedure.

### Neighbors Message (0x04)

```text
message Neighbours {
  Endpoint from = 1;
  repeated Endpoint neighbours = 2;
  int64 timestamp = 3;
}
```

Neighbors is the reply to [FindNeighbours].

[Ping]: #ping-message-(0x01)
[Pong]: #pong-message-(0x02)
[FindNeighbours]: #findneighbours-message-(0x03)
[Neighbors]: #neighbors-message-(0x04)

