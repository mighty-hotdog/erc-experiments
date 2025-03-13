# ERC2612 - "permit" extension to ERC20

**A study of the "permit" mechanism.**

## Key Function
    function permit(
        address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s
        ) external;

## Important Terms and Concepts
- digest:   A representation of the owner's original message granting approval to adjust his allowance to the spender.
            This is what the owner signed beforehand with his private key to produce the "signature".

- signature:    Represented as 3 values v r and s.
                The signing process is a series of cryptographic operations involving the secp256k1 elliptic curve.
                The signing process produces 3 values v r and s.
                These values v r s together is referred to as "the signature".
                v r and s are provided as input params to the ERC2612 permit() function.

- secp256k1:    A specific elliptic curve defined over a finite field.
                Standardized by the Standards for Efficient Cryptography (SEC) group.
                Its full name is "Standards for Efficient Cryptography Prime 256-bit Koblitz curve 1."
                Used with the Elliptic Curve Digital Signature Algorithm (ECDSA) to:
                - Generate Key Pairs:
                  - A private key is a random 256-bit number (between 1 and the curve’s order, ( n )).
                  - A public key is a point ((x, y)) on the curve, computed by multiplying the private key by a fixed generator point ( G ) using elliptic curve point multiplication.

                - Sign Messages:
                  ECDSA uses the private key to sign a message (e.g., a transaction or an ERC-2612 permit digest), producing a signature ((r, s)) and a recovery parameter ( v ).

                - Verify Signatures:
                  The public key verifies the signature, ensuring the message hasn’t been tampered with and was signed by the private key holder.

- PERMIT_TYPEHASH:  A 32-byte hash constant:
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

                    It is the hashed "type-definition" of the ERC2612 permit() message from the owner.
                    ie: this type-definition lays out how the message is structured - the fields, the names, the types - allowing verifiers to extract and check each component.

                    Defined in token contracts that implement ERC2612.
                    Used in the ERC2612 permit() function to recreate the message "digest".

- DOMAIN_SEPARATOR: A 32-byte hash:
                        keccak256(
                            abi.encode(
                                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                                keccak256(bytes(name)),
                                keccak256(bytes(version)),
                                chainId,
                                address(this)
                            )
                        );

                    Defined by EIP-712.
                    Uniquely identifies the contract and its deployment context, in which a signature is applicable and valid.
                    Used to bind a signature to a specific contract on a specific blockchain.
                    Calculated once at deployment and then stored in the contract.

                    Components:
                    - type hash for the domain descriptor, constant, similar to PERMIT_TYPEHASH:
                        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")

                    - hashed contract name:
                        keccak256(bytes(name))

                    - hashed contract version:
                        keccak256(bytes(version))

                    - chainid, aka "chainId" in the type hash
                    - contract address, aka "verifyingContract" in the type hash



## What the ERC2612 permit() function does
1. Compares current time (ie: block.timestamp) vs the deadline for the signature.
   If exceeded, revert.
   If not exceeded, proceed.

2. Recreates the "digest" aka the original message the owner signed earlier with his private key.
        digest = keccak256(
                    abi.encodePacked(
                        hex"1901",
                        DOMAIN_SEPARATOR,
                        keccak256(
                            abi.encode(
                                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                                owner,
                                spender,
                                value,
                                nonce,
                                deadline)
                        )
                    )
                 );

   Step 1: The PERMIT_TYPEHASH constant is abi-encoded with the actual values of each message field to produce an abi-compliant version of the original owner's message.

   Step 2: This abi-compliant original message is then keccak256 hashed to produce the "struct hash".

   Step 3: This "struct hash" is then combined with:
   - "\x19\x01"
   - DOMAIN_SEPARATOR
   and then abi-encodePacked and then hashed again with keccak256 to produce the message aka "digest" that the owner signed earlier with his private key.

   Note: The \x19\x01 prefix (from EIP-191) ensures the digest is Ethereum-specific and prevents certain signature malleability attacks.

1. Uses the recover() function (from the OpenZep library ECDSA) to extract the owner's address from the v r s values (aka "the signature")
   and the "digest".

   Note: The OpenZep library ECDSA function recover() extracts the public key (aka address of the owner) from the v r s values (aka "the signature") and the "digest".

2. Compares the extracted owner's address to input param to see if it matches.
   If match, means the signature (ie: v r s) is valid/verified, proceed.
   If not match, revert.

3. Calls approve() to adjust owner's allowance granted to the spender.

## Importance and Adoption
Widespread adoption among new tokens and major protocols. Considered a standard feature in modern token design.