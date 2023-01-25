// SPDX-License-Identifier: MIT

// PRAGMA
pragma solidity ^0.8.8;

//IMPORTS
import "./PriceConverter.sol";
import "hardhat/console.sol";

//Gas reduction hacks

// ERROR CODES
error FundMe__NotOwner();

// INTERFACES, LIBRARIES

/** @title A contract for crowdFunding
 * @author Siki_02
 * @notice This contract is to demo a sample funding contract
 * @dev This implements price feeds as our library
 */

//CONTRACTS

contract fundMe {
    // Type declaration
    using PriceConverter for uint256;

    //State variables
    uint256 public constant MINIMUM_USD = 50 * 1e18;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    //Modifier

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Your are not the owner!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    //Receive and fallback functions
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough funds."
        );
        // 18 decimales places in one ETH
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public payable onlyOwner {
        for (uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        //Reset the array
        s_funders = new address[](0);
        //Actually withdraw funds

        // //Transfer
        // payable(msg.sender).transfer(address(this).balance);
        //send
        (bool succes, ) = i_owner.call{value: address(this).balance}("");
        require(succes);
        // //call
        // (bool callSuccess, ) = payable(msg.sender).call{
        //     value: address(this).balance
        // }("");
        // require(callSuccess, "Call Failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        // mappings can't be in memory
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool succes, ) = i_owner.call{value: address(this).balance}("");
        require(succes);
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index_f) public view returns (address) {
        return s_funders[index_f];
    }

    function getAddressToAmountFunded(
        address funder
    ) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
