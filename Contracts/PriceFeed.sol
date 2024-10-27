// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@api3/contracts/api3-server-v1/proxies/interfaces/IProxy.sol";
import "@openzeppelin/contracts@4.9.3/access/Ownable.sol";

contract API3PriceFeed is Ownable {

    address public proxyAddress;

    function setProxyAddress (address _proxyAddress) public onlyOwner {
        proxyAddress = _proxyAddress;
    }

    function readDataFeed() external view returns (int224 value, uint256 timestamp) {
        (value, timestamp) = IProxy(proxyAddress).read();
    }

    // Function to payout $10 worth of ETH to a specific address
    function payoutInEth(address recipient) external payable onlyOwner {
        require(proxyAddress != address(0), "Proxy address not set");

        // Fetch the current ETH/USD price from the proxy contract
        (int224 ethUsdPrice, ) = IProxy(proxyAddress).read();
        require(ethUsdPrice > 0, "Invalid ETH/USD price");

        // Calculate the amount of ETH equivalent to $10
        uint256 usdAmount = 10 * 1e18; // $10 in wei for precision
        uint256 ethAmount = usdAmount / uint224(ethUsdPrice);

        // Ensure the contract has enough balance for the payout
        require(address(this).balance >= ethAmount, "Insufficient balance in contract");

        // Transfer the calculated ETH amount to the recipient
        payable(recipient).transfer(ethAmount);
    }

    // Function to allow the contract to receive ETH
    receive() external payable {}
}
