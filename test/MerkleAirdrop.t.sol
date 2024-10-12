// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {DeeneyToken} from "src/DeeneyToken.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop airdrop;
    DeeneyToken token;
    DeployMerkleAirdrop deployer;

    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32 public ROOT = 0x6bfb279d45cbb42a0977c3c08e2fc716a0f6a35e0e8b5b0a53bf6a55f4dfa4a9;
    bytes32[] public PROOF = [proofOne, proofTwo];
    uint256 public AMOUNT_TO_CLAIM = 25e18;
    uint256 public AMOUNT_TOKEN = 100e18;
    address  public user;
    uint256 userPrivKey;
    address public gasPayer;

    function setUp() public {
        deployer = new DeployMerkleAirdrop();
        (airdrop, token) = deployer.deployMerkleAirdrop();
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function signMessage(uint256 privKey, address account) public view returns(uint8 v, bytes32 r, bytes32 s){
        bytes32 headMessage = airdrop.getMessageHash(account, AMOUNT_TO_CLAIM);
        (v, r, s) = vm.sign(privKey, headMessage);
    }

    function testuserClaimToken() public {
        uint256 startingBalance = token.balanceOf(user);

        // user sign the message using the private key and the hash of the message.
        vm.startPrank(user);
        (uint8 v, bytes32 r, bytes32 s) = signMessage(userPrivKey, user);
        vm.stopPrank();

        // Prank the gasPayer to claim for the user using the signer
        vm.prank(gasPayer);
        airdrop.claimToken(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance: ", endingBalance);
        assertEq((endingBalance - startingBalance), AMOUNT_TO_CLAIM);
    }
}
// 0x8c592e14d9555Af5EDeEA65b23C0991B03739019