// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;
pragma abicoder v2;
pragma experimental ABIEncoderV2;

import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';

contract LiquidityFunc {

      struct Deposit {
            address owner;
            uint128 liquidity;
            address token0;
            address token1;
      }

      // Token's address
      address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
      address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

      uint24 public constant poolFee = 3000;
      mapping(uint256 => Deposit) public deposits;

      INonfungiblePositionManager public immutable nonfungiblePositionManager;

      function _createDeposit(address owner, uint256 tokenId, INonfungiblePositionManager nonfungiblePositionManager) external {
            (, , address token0, address token1, , , , uint128 liquidity, , , , ) = 
                  nonfungiblePositionManager.positions(tokenId);

            // set the owner and data for position
            // operator is msg.sender
            deposits[tokenId] = Deposit({owner: owner, liquidity: liquidity, token0: token0, token1: token1});
      }

      
}