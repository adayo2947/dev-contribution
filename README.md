# Proof of Contribution (Soulbound Token) Smart Contract

This Clarity smart contract allows minting non-transferable NFTs (Soulbound Tokens or SBTs) to recognize developer contributions. Each token represents a unique contribution, identified by a hash (e.g., a Git commit hash), and can only be minted by the contract owner.

---

## Features

- **Minting:** Only the contract owner can mint tokens.
- **Non-transferable:** Tokens are soulbound and cannot be transferred.
- **Metadata:** Each token stores:
  - Contributor's principal (address)
  - Contribution hash (string, e.g., commit hash)
  - Timestamp of minting (block height)
- **Query Functions:** Retrieve contribution details, token owner, and last minted token ID.

---

## Constants

| Constant           | Error Code | Description                  |
|--------------------|------------|------------------------------|
| `ERR-NOT-AUTHORIZED` | `u100`     | Unauthorized action          |
| `ERR-TRANSFER-BLOCKED` | `u101`     | Token transfer is blocked    |
| `ERR-TOKEN-NOT-FOUND` | `u102`     | Token ID does not exist      |

---

## Public Functions

### `mint-contribution(recipient: principal, contribution-hash: (string-ascii 64))`

Mints a new contribution SBT to the specified recipient.

- Only callable by the contract owner.
- Stores metadata including contributor, contribution hash, and timestamp.
- Returns the newly minted token ID.

### `transfer(token-id: uint, sender: principal, recipient: principal)`

Disabled function to comply with SIP-009 NFT trait. Attempting to transfer will fail with `ERR-TRANSFER-BLOCKED`.

---

## Read-Only Functions

### `get-contribution(token-id: uint)`

Returns contribution details for the given token ID:
- `contributor`: principal
- `hash`: contribution hash (string)
- `timestamp`: mint block height

Returns `ERR-TOKEN-NOT-FOUND` if the token does not exist.

### `get-owner(token-id: uint)`

Returns the owner (principal) of the specified token ID.

### `get-last-token-id()`

Returns the last minted token ID.

---

## Usage

1. Deploy the contract to the Stacks blockchain.
2. As the contract owner, call `mint-contribution` with the recipient principal and contribution hash.
3. Use the read-only functions to verify minted tokens and their metadata.

---


Inspired by the concept of Soulbound Tokens (SBTs) for developer recognition and contribution tracking.

