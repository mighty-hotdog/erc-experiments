## ERC20

**An exploration of the ERC20 and related token standards.**

As part of the learning journey, some realworld tokens with specific uses/functionality will also be explored.
eg: Link, Eth, Btc, etc

Related token standards:

-   **ERC223**: Improves ERC20. Modifies the original ERC20 token contract "transfer" function to call a "tokenReceived"
                callback on the receiver if it is a contract. If receiving contract does not implement "tokenReceived",
                the "transfer" call in the token contract must revert.
-   **ERC677**: Add-on to ERC20. Introduces a new function "transferAndCall" which transfers tokens to a receiving contract,
                then calls the receiving contract's "onTokenTransfer" function with the (optional) additional data provided
                in the "transferAndCall".
                As this is an add-on to ERC20, it is fully backward compatible with existing receiving contracts w/o
                "onTokenTransfer". Token contract can still transfer tokens to these via the original ERC20 mechanism of
                "transfer", "transferFrom", and "approve" functions.
-   **ERC1363**: Extends ERC20. Similiar design intent to ERC677 but adds "transferAndCall", "transferFromAndCall" and
                 "approveAndCall" functions to the original ERC20 token standard, which call "onTransferReceived" and
                 "onApprovalReceived" on the receiving contracts.
                 Requires full implementation of ERC20.
                 Fully backward compatible with existing receiving contracts w/o "onTransferReceived" and/or
                 "onApprovalReceived". Token contract can still transfer tokens to these via the original ERC20 mechanism
                 of "transfer", "transferFrom" and "approve" functions.
-   **ERC4626**: Extends ERC20. Provides a standard API for tokenized Vaults representing shares of a single underlying
                 ERC20 token. Requires full implementation of ERC20.
-   **ERC165**: Add-on standard. Provides a standard method to publish and detect what interfaces a smart contract implements.
-   **ERC777**: To be explored further.
-   **ERC1155**: Provides a smart contract interface that can represent any number of fungible and non-fungible token types.
                 Existing standards such as ERC20 require deployment of separate contracts per token type. The ERC721
                 standard’s token ID is a single non-fungible index and the group of these non-fungibles is deployed as a
                 single contract with settings for the entire collection.
                 In contrast, the ERC1155 Multi Token Standard allows for each token ID to represent a new configurable
                 token type, which may have its own metadata, supply and other attributes.
-   **ERC721**: A standard interface for non-fungible tokens.
-   **ERC2981**: A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
                 support for royalty payments across all NFT marketplaces and ecosystem participants.

## Documentation

-   ERC20   https://eips.ethereum.org/EIPS/eip-20
-   ERC223  https://eips.ethereum.org/EIPS/eip-223
-   ERC677  https://github.com/ethereum/EIPs/issues/677
-   ERC1363 https://eips.ethereum.org/EIPS/eip-1363
-   ERC4626 https://eips.ethereum.org/EIPS/eip-4626
-   ERC165  https://eips.ethereum.org/EIPS/eip-165
-   ERC777  https://eips.ethereum.org/EIPS/eip-777
-   ERC1155 https://eips.ethereum.org/EIPS/eip-1155
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