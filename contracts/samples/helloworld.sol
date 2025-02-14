// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
import "../BoringBox.sol";

// An example a contract that stores tokens in the BentoBox.
// A single contract that users can approve for the BentoBox, hence the registerProtocol call.
// PS. This isn't good code, just kept it simple to illustrate usage.
contract HelloWorld {
    BoringBox public immutable yieldBox;
    IERC20 public immutable token;
    IStrategy public immutable strategy;
    uint256 public immutable asset;

    constructor(BoringBox _yieldBox, IERC20 _token, IStrategy _strategy) public {
        yieldBox = _yieldBox;
        token = _token;
        strategy = _strategy;
        asset = _yieldBox.registerAsset(_token, _strategy);
    }

    mapping(address => uint256) public yieldBoxShares;

    // Deposits an amount of token into the BentoBox. BentoBox shares are given to the HelloWorld contract and
    // assigned to the user in bentoBoxShares.
    // Don't deposit twice, you'll lose the first deposit ;)
    function deposit(uint256 amount) public {
        (, yieldBoxShares[msg.sender]) = yieldBox.deposit(asset, msg.sender, address(this), amount, 0);
    }

    // This will return the current value in amount of the BentoBox shares.
    // Through flash loans and maybe a strategy, the value can go up over time.
    function balance() public view returns (uint256 amount) {
        return yieldBox.toAmount(asset, yieldBoxShares[msg.sender], false);
    }

    // Withdraw all shares from the BentoBox and receive the token.
    function withdraw() public {
        yieldBox.withdraw(asset, address(this), msg.sender, 0, yieldBoxShares[msg.sender]);
    }
}
