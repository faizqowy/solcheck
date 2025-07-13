// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleEscrow {
    address public immutable payer;
    address public immutable payee;
    uint256 public immutable amount;

    bool public immutable isFunded;
    bool public isReleased;

    constructor(address _payee) payable {
        require(_payee != address(0), "Payee address cannot be 0");
        payer = msg.sender;
        payee = _payee;
        amount = msg.value;
        isFunded = msg.value > 0;
    }

    function release() public {
        require(msg.sender == payer, "Only payer can release funds");
        require(isFunded, "Escrow not funded");
        require(!isReleased, "Already released");

        isReleased = true;
        (bool success, ) = payee.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function cancel() public {
        require(msg.sender == payer, "Only payer can cancel");
        require(!isReleased, "Already released");

        (bool success, ) = payer.call{value: address(this).balance}("");
        require(success, "Refund failed");
    }
}
