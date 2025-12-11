// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HelloWorld {
    string public yourName;

    constructor() {
        yourName = "Unknown";
    }

    function setName(string memory newName) public {
        yourName = newName;
    }
}
