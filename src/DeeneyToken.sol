//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract DeeneyToken is ERC20, Ownable {
    constructor() ERC20("Deeney", "DEEN") Ownable(msg.sender) {} // whoever deploys the contract will be owner of the token

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
