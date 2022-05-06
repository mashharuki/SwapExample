// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';


contract SingleSwap {
    
      // This example swaps DAI/WETH9 for single path swaps and DAI/USDC/WETH9 for multi path swaps.

      ISwapRouter public immutable swapRouter;
      // Token's address
      address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
      address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
      address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

      // For this example, we will set the pool fee to 0.3%.
      uint24 public constant poolFee = 3000;

      // constructor
      constructor(ISwapRouter _swapRouter) {
            swapRouter = _swapRouter;
      }
      
      function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {
            // msg.sender must approve this contract
            // Transfer the specified amount of DAI to this contract.
            TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amountIn);
            // Approve the router to spend DAI.
            TransferHelper.safeApprove(DAI, address(swapRouter), amountIn);

            ISwapRouter.ExactInputSingleParams memory params = 
                  ISwapRouter.ExactInputSingleParams({
                        tokenIn: DAI,
                        tokenOut: WETH9,
                        fee: poolFee,
                        recipient: msg.sender,
                        deadline: block.timestamp,
                        amountIn: amountIn,
                        amountOutMinimum: 0,
                        sqrtPriceLimitX96: 0
                  });

            // The call to `exactInputSingle` executes the swap.
            amountOut = swapRouter.exactInputSingle(params);
      }

      function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {

            // Transfer the specified amount of DAI to this contract.
            TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amountInMaximum);
            // Approve the router to spend the specified `amountInMaximum` of DAI.
            TransferHelper.safeApprove(DAI, address(swapRouter), amountInMaximum);

            ISwapRouter.ExactOutputSingleParams memory params =
                  ISwapRouter.ExactOutputSingleParams({
                        tokenIn: DAI,
                        tokenOut: WETH9,
                        fee: poolFee,
                        recipient: msg.sender,
                        deadline: block.timestamp,
                        amountOut: amountOut,
                        amountInMaximum: amountInMaximum,
                        sqrtPriceLimitX96: 0
                  });

            // Executes the swap returning the amountIn needed to spend to receive the desired amountOut.
            amountIn = swapRouter.exactOutputSingle(params);

            // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the msg.sender and approve the swapRouter to spend 0.
            if (amountIn < amountInMaximum) {
                  TransferHelper.safeApprove(DAI, address(swapRouter), 0);
                  TransferHelper.safeTransfer(DAI, msg.sender, amountInMaximum - amountIn);
            }
      }

}