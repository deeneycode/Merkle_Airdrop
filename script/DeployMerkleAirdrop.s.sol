// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {DeeneyToken} from "src/DeeneyToken.sol";

contract DeployMerkleAirdrop is Script {
    DeeneyToken token;
    MerkleAirdrop airdrop;

    bytes32 private s_merkleRoot = 0x6bfb279d45cbb42a0977c3c08e2fc716a0f6a35e0e8b5b0a53bf6a55f4dfa4a9;
    uint256 private s_amountToMint = 100e18;
    // error owner: 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38

    function deployMerkleAirdrop() public returns (MerkleAirdrop, DeeneyToken) {
        vm.startBroadcast();
        token = new DeeneyToken();
        token.mint(token.owner(), s_amountToMint);
        airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(token));
        token.transferOwnership(address(airdrop));
        IERC20(token).transfer(address(airdrop), s_amountToMint);
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() external returns (MerkleAirdrop, DeeneyToken) {
        return deployMerkleAirdrop();
    }
}
