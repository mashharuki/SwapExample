// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

contract MultihopSwap {

      ISwapRouter public immutable swapRouter;

      // This example swaps DAI/WETH9 for single path swaps and DAI/USDC/WETH9 for multi path swaps.
      address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
      address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
      address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

      // For this example, we will set the pool fee to 0.3%.
      uint24 public constant poolFee = 3000;

      // constructor
      constructor(ISwapRouter _swapRouter) {
            swapRouter = _swapRouter;
      }

      function swapExactInputMultihop(uint256 amountIn) external returns (uint256 amountOut) {
            // Transfer `amountIn` of DAI to this contract.
            TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amountIn);
            // Approve the router to spend DAI.
            TransferHelper.safeApprove(DAI, address(swapRouter), amountIn);

            ISwapRouter.ExactInputParams memory params =
                  ISwapRouter.ExactInputParams({
                        path: abi.encodePacked(DAI, poolFee, USDC, poolFee, WETH9),
                        recipient: msg.sender,
                        deadline: block.timestamp,
                        amountIn: amountIn,
                        amountOutMinimum: 0
                  });

            // Executes the swap.
            amountOut = swapRouter.exactInput(params);
      }

      function swapExactOutputMultihop(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {
            // Transfer the specified `amountInMaximum` to this contract.
            TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amountInMaximum);
            // Approve the router to spend  `amountInMaximum`.
            TransferHelper.safeApprove(DAI, address(swapRouter), amountInMaximum);

            ISwapRouter.ExactOutputParams memory params =
                  ISwapRouter.ExactOutputParams({
                        path: abi.encodePacked(WETH9, poolFee, USDC, poolFee, DAI),
                        recipient: msg.sender,
                        deadline: block.timestamp,
                        amountOut: amountOut,
                        amountInMaximum: amountInMaximum
                  });
                  
            // Executes the swap, returning the amountIn actually spent.
            amountIn = swapRouter.exactOutput(params);

            // If the swap did not require the full amountInMaximum to achieve the exact amountOut then we refund msg.sender and approve the router to spend 0.
            if (amountIn < amountInMaximum) {
                  TransferHelper.safeApprove(DAI, address(swapRouter), 0);
                  TransferHelper.safeTransferFrom(DAI, address(this), msg.sender, amountInMaximum - amountIn);
            }
      }
}