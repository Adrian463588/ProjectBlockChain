// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleHotelBooking {
    address public hotelOwner;
    // uint256 public roomPrice = 0.0001 sepolia ;
    uint256 public roomPrice = 0 ether;
    uint256 public availableRooms;

    mapping(address => uint256) public bookedRooms;

    event RoomBooked(address guest, uint256 numberOfRooms);

    modifier onlyHotelOwner() {
        require(msg.sender == hotelOwner, "Only hotel owner can call this function");
        _;
    }

    modifier hasEnoughBalance(uint256 totalPrice) {
        require(msg.value >= totalPrice, "Insufficient funds to book room");
        _;
    }

    modifier hasAvailableRooms(uint256 numberOfRooms) {
        require(availableRooms >= numberOfRooms, "Insufficient available rooms");
        _;
    }

    constructor(uint256 initialRooms) {
        hotelOwner = msg.sender;
        availableRooms = initialRooms;
    }

    function bookRoom(uint256 numberOfRooms) external payable hasEnoughBalance(roomPrice * numberOfRooms) hasAvailableRooms(numberOfRooms) {
        bookedRooms[msg.sender] += numberOfRooms;
        availableRooms -= numberOfRooms;

        emit RoomBooked(msg.sender, numberOfRooms);
    }

    function cancelBooking(uint256 numberOfRooms) external {
        require(bookedRooms[msg.sender] >= numberOfRooms, "Not enough booked rooms to cancel");

        bookedRooms[msg.sender] -= numberOfRooms;
        availableRooms += numberOfRooms;
    }

    function checkFunds() external view returns (uint256) {
        return address(this).balance;
    }

    function withdrawBalance() external onlyHotelOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No balance to withdraw");

        payable(hotelOwner).transfer(contractBalance);
    }
}
