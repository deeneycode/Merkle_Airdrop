// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712{
    using SafeERC20 for IERC20;
    // some list of addresses
    // Allow some in the list to claim token
    /**
     * Errors
     */

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__HasAlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    /** Struct */
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /**
     * Events
     */
    event Claimed(address indexed account, uint256 amount);

    /**
     * State variables
     */
    address[] claimers;
    bytes32 public immutable i_merkleProof;
    IERC20 public immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    constructor(bytes32 merkleProof, IERC20 airdropToken) EIP712 ("MerkleAirdrop", "1"){
        i_merkleProof = merkleProof;
        i_airdropToken = airdropToken;
    }

    function claimToken(address account, uint256 amountToClaim, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) external {
        // Calculate using the account and the amount, the hash -> leaf node
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encodePacked(claimers, amountToClaim))));
        // Check if the account has already claimed
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__HasAlreadyClaimed();
        }
        // check the signature
        if(!_isValidSignature(account, getMessageHash(account, amountToClaim), v, r, s)){
            revert MerkleAirdrop__InvalidSignature();
        }
        // Verify how leaf using merkle proof
        if (MerkleProof.verify(merkleProof, i_merkleProof, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[account] = true;
        i_airdropToken.safeTransfer(account, amountToClaim);
        emit Claimed(account, amountToClaim);
    }

    function getMessageHash(address account, uint256 amount) public view returns(bytes32){
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount})))
        );
    }

    /** Internal function */
    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns (bool) {
        (address actualSigner, , ) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }

    /**
     * Getters functions
     */
    function getMerkleProof() external view returns (bytes32) {
        return i_merkleProof;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
