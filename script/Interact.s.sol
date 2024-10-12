// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script{
    error _ClaimAirdrop__InvalidSignature();

    address public ADDRESS_TO_CLAIM = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 AMOUNT_TO_CLAIM = 25e18;

    bytes32 PROOF_ONE = 0x4fd31fee0e75780cd67704fbc43caee70fddcaa43631e2e1bc9fb233fada2394;
    bytes32 PROOF_TWO = 0x354023b6697c06f5429b21244a5bf519b5f3eb38e891a2cc9629d0723ce9d5e0;
    bytes32[] proof = [PROOF_ONE, PROOF_TWO];
    bytes  private SIGNATURE = hex"53664c6a72469973e51ccc89aa148ea8801200cfbc32e51d90f78c7e32918c152b1f3a6cb187e33e78884581d2543d6cf500d22cc34bc3e5a0ac9c00b27715ac1c";


    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claimToken(ADDRESS_TO_CLAIM, AMOUNT_TO_CLAIM, proof, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if(sig.length != 65) {
            revert _ClaimAirdrop__InvalidSignature();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }

}