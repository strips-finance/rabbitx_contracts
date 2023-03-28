// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "hardhat/console.sol";

contract RabbitDeposit {

    address public immutable owner;
    address public immutable rabbit;
    IERC20 public paymentToken;

    // total of trader's deposits to date
    mapping(address => uint) public deposits;

    uint nextDepositId = 30001;

    struct Receipt {
        uint fromAddress;
        address toAddress;
        uint[] payload;
    }

    event Deposit(uint indexed id, address indexed trader, uint amount);

    constructor(address _owner, address _rabbit, address _paymentToken) {
        owner = _owner;
        rabbit = _rabbit;
        paymentToken = IERC20(_paymentToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "ONLY_OWNER");
        _;
    }

    function setPaymentToken(address _paymentToken) external onlyOwner {
        paymentToken = IERC20(_paymentToken);
    }

    function allocateDepositId() private returns (uint depositId) {
        depositId = nextDepositId;
        nextDepositId++;
        return depositId;
    }

    function deposit(uint amount) external {
        bool success = makeTransferFrom(msg.sender, rabbit, amount);
        require(success, "TRANSFER_FAILED");
        deposits[msg.sender] += amount;
        uint depositId = allocateDepositId();
        emit Deposit(depositId, msg.sender, amount);
    }

    // function makeTransfer(address to, uint256 amount) private returns (bool success) {
    //     return tokenCall(abi.encodeWithSelector(paymentToken.transfer.selector, to, amount));
    // }

    function makeTransferFrom(address from, address to, uint256 amount) private returns (bool success) {
        return tokenCall(abi.encodeWithSelector(paymentToken.transferFrom.selector, from, to, amount));
    }

    function tokenCall(bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(paymentToken).call(data);
        if (success && returndata.length > 0) {
            success = abi.decode(returndata, (bool));
        }
        return success;
    }
}
