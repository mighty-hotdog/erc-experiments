## ERC20

**An exploration of the ERC20 and related token standards.**

As part of the learning journey, some realworld tokens with specific uses/functionality will also be explored.
eg: Link, Eth, BTC, etc

Related token standards:

-   **ERC223**: Improves and replaces ERC20. Modifies the original ERC20 token contract "transfer" function to call a
                "tokenReceived" callback on the receiver if it is a contract. If receiving contract does not implement
                "tokenReceived", the "transfer" call in the token contract must revert.
-   **ERC677**: Add-on to ERC20. Introduces a new function "transferAndCall" which transfers tokens to a receiving contract,
                then calls the receiving contract's "onTokenTransfer" function with the (optional) additional data provided
                in the "transferAndCall".
                As this is an add-on to ERC20, it is fully backward compatible with existing ERC20 receiving contracts w/o
                "onTokenTransfer". Token contract can still transfer tokens to these via the original ERC20 mechanism of
                "transfer", "transferFrom", and "approve" functions.
-   **ERC1363**: Attempt to replace ERC20. For reference.
                 Similiar design intent to ERC677 but adds "transferAndCall", "transferFromAndCall" and "approveAndCall"
                 functions to the original ERC20 token standard, which call "onTransferReceived" and "onApprovalReceived"
                 on the receiving contracts.
                 Requires full implementation of ERC20.
                 Fully backward compatible with existing receiving contracts w/o "onTransferReceived" and/or
                 "onApprovalReceived". Token contract can still transfer tokens to these via the original ERC20 mechanism
                 of "transfer", "transferFrom" and "approve" functions.
-   **ERC777**: Another attempt to replace ERC20. For reference.
-   **ERC2612**: EIP-20 approvals via EIP-712 secp256k1 signatures.
-   **ERC4626**: Tokenized vaults for ERC20 tokens.
                 Provides a standard API for tokenized Vaults representing shares of a single underlying
                 ERC20 token. Requires full implementation of ERC20.
-   **ERC165**: Add-on standard. Provides a standard method to publish and detect what interfaces a smart contract implements.
-   **ERC1155**: Multi token standard. Provides a smart contract interface that can represent any number of fungible and
                 non-fungible token types.
                 Existing standards such as ERC20 require deployment of separate contracts per token type. The ERC721
                 standard’s token ID is a single non-fungible index and the group of these non-fungibles is deployed as a
                 single contract with settings for the entire collection.
                 In contrast, the ERC1155 Multi Token Standard allows for each token ID to represent a new configurable
                 token type, which may have its own metadata, supply and other attributes.
-   **ERC3156**: Flash loan standard.
-   **ERC4337**: Account abstraction standard.
-   **ERC721**: A standard interface for non-fungible tokens. Note the related ERC721a.
-   **ERC2981**: A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
                 support for royalty payments across all NFT marketplaces and ecosystem participants.

## Documentation

-   ERC20   https://eips.ethereum.org/EIPS/eip-20
-   ERC223  https://eips.ethereum.org/EIPS/eip-223
-   ERC677  https://github.com/ethereum/EIPs/issues/677
-   ERC1363 https://eips.ethereum.org/EIPS/eip-1363
-   ERC777  https://eips.ethereum.org/EIPS/eip-777
-   ERC2612 https://eips.ethereum.org/EIPS/eip-2612
-   ERC4626 https://eips.ethereum.org/EIPS/eip-4626
-   ERC165  https://eips.ethereum.org/EIPS/eip-165
-   ERC1155 https://eips.ethereum.org/EIPS/eip-1155
-   ERC3156 https://eips.ethereum.org/EIPS/eip-3156
-   ERC4337 https://eips.ethereum.org/EIPS/eip-4337
-   ERC721  https://eips.ethereum.org/EIPS/eip-721
-   ERC2981 https://eips.ethereum.org/EIPS/eip-2981

## Requirements

To compile and run this code, you will need
[git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and
[foundry](https://getfoundry.sh/)


## Libraries Required

```
forge install foundry-rs/forge-std --no-commit
forge install OpenZeppelin/openzeppelin-contracts --no-commit

```

## Quickstart

Clone to your local repo and build.
```
git clone https://github.com/saracen75/erc-experiments
cd erc-experiments
forge build
```

## TODOs
1. ~~ownership mechanism~~ DONE
2. ~~pausable mechanism~~ DONE
3. ~~capping mechanism~~ DONE
4. ~~wrapper mechanism~~ DONE
5. ERC677 extension
6. ERC165 extension
7. ERC2612 aka permit extension
8. ERC4626 extension
9. ERC1155 extension
10. ERC4337 extension
11. ERC3156 extension