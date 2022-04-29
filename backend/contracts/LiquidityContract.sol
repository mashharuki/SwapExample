// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;
pragma abicoder v2;
pragma experimental ABIEncoderV2;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/base/LiquidityManagement.sol';

contract LiquidityContract is IERC721Receiver {

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

      // counstructor
      constructor(INonfungiblePositionManager _nonfungiblePositionManager) {
            nonfungiblePositionManager = _nonfungiblePositionManager;
      }

      function onERC721Received(address operator, address, uint256 tokenId, bytes calldata) external override returns (bytes4) {
            // get position information
            _createDeposit(operator, tokenId);
            return this.onERC721Received.selector;
      }

      function collectAllFees(uint256 tokenId) external returns (uint256 amount0, uint256 amount1) {
            // Caller must own the ERC721 position
            nonfungiblePositionManager.safeTransferFrom(msg.sender, address(this), tokenId);

            // set amount0Max and amount1Max to uint256.max to collect all fees
            INonfungiblePositionManager.CollectParams memory params =
                  INonfungiblePositionManager.CollectParams({
                        tokenId: tokenId,
                        recipient: address(this),
                        amount0Max: type(uint128).max,
                        amount1Max: type(uint128).max
                  });

            (amount0, amount1) = nonfungiblePositionManager.collect(params);

            // send collected feed back to owner
            _sendToOwner(tokenId, amount0, amount1);
      }

      function mintNewPosition() external returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) {
            // For this example, we will provide equal amounts of liquidity in both assets.
            // Providing liquidity in both assets means liquidity will be earning fees and is considered in-range.
            uint256 amount0ToMint = 1000;
            uint256 amount1ToMint = 1000;
            // Approve the position manager
            TransferHelper.safeApprove(DAI, address(nonfungiblePositionManager), amount0ToMint);
            TransferHelper.safeApprove(USDC, address(nonfungiblePositionManager), amount1ToMint);

            INonfungiblePositionManager.MintParams memory params =
                  INonfungiblePositionManager.MintParams({
                        token0: DAI,
                        token1: USDC,
                        fee: poolFee,
                        tickLower: TickMath.MIN_TICK,
                        tickUpper: TickMath.MAX_TICK,
                        amount0Desired: amount0ToMint,
                        amount1Desired: amount1ToMint,
                        amount0Min: 0,
                        amount1Min: 0,
                        recipient: address(this),
                        deadline: block.timestamp
                  });

            // Note that the pool defined by DAI/USDC and fee tier 0.3% must already be created and initialized in order to mint
            (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);

            // Create a deposit
            _createDeposit(msg.sender, tokenId);

            // Remove allowance and refund in both assets.
            if (amount0 < amount0ToMint) {
                  TransferHelper.safeApprove(DAI, address(nonfungiblePositionManager), 0);
                  uint256 refund0 = amount0ToMint - amount0;
                  TransferHelper.safeTransfer(DAI, msg.sender, refund0);
            }

            if (amount1 < amount1ToMint) {
                  TransferHelper.safeApprove(USDC, address(nonfungiblePositionManager), 0);
                  uint256 refund1 = amount1ToMint - amount1;
                  TransferHelper.safeTransfer(USDC, msg.sender, refund1);
            }
      }

      function decreaseLiquidityInHalf(uint256 tokenId) external returns (uint256 amount0, uint256 amount1) {
            // caller must be the owner of the NFT
            require(msg.sender == deposits[tokenId].owner, 'Not the owner');
            // get liquidity data for tokenId
            uint128 liquidity = deposits[tokenId].liquidity;
            uint128 halfLiquidity = liquidity / 2;

            // amount0Min and amount1Min are price slippage checks
            // if the amount received after burning is not greater than these minimums, transaction will fail
            INonfungiblePositionManager.DecreaseLiquidityParams memory params =
                  INonfungiblePositionManager.DecreaseLiquidityParams({
                        tokenId: tokenId,
                        liquidity: halfLiquidity,
                        amount0Min: 0,
                        amount1Min: 0,
                        deadline: block.timestamp
                  });

            (amount0, amount1) = nonfungiblePositionManager.decreaseLiquidity(params);
            //send liquidity back to owner
            _sendToOwner(tokenId, amount0, amount1);
      }

      function increaseLiquidityCurrentRange(uint256 tokenId, uint256 amountAdd0, uint256 amountAdd1) external returns (uint128 liquidity, uint256 amount0, uint256 amount1){
            TransferHelper.safeTransferFrom(deposits[tokenId].token0, msg.sender, address(this), amountAdd0);
            TransferHelper.safeTransferFrom(deposits[tokenId].token1, msg.sender, address(this), amountAdd1);

            TransferHelper.safeApprove(deposits[tokenId].token0, address(nonfungiblePositionManager), amountAdd0);
            TransferHelper.safeApprove(deposits[tokenId].token1, address(nonfungiblePositionManager), amountAdd1);

            INonfungiblePositionManager.IncreaseLiquidityParams memory params =
                  INonfungiblePositionManager.IncreaseLiquidityParams({
                        tokenId: tokenId,
                        amount0Desired: amountAdd0,
                        amount1Desired: amountAdd1,
                        amount0Min: 0,
                        amount1Min: 0,
                        deadline: block.timestamp
                  });

            (liquidity, amount0, amount1) = nonfungiblePositionManager.increaseLiquidity(params);
      }

      function _createDeposit(address owner, uint256 tokenId) internal {
            (, , address token0, address token1, , , , uint128 liquidity, , , , ) = 
                  nonfungiblePositionManager.positions(tokenId);

            // set the owner and data for position
            // operator is msg.sender
            deposits[tokenId] = Deposit({owner: owner, liquidity: liquidity, token0: token0, token1: token1});
      }

      function _sendToOwner(uint256 tokenId, uint256 amount0, uint256 amount1) internal {
            // get owner of contract
            address owner = deposits[tokenId].owner;

            address token0 = deposits[tokenId].token0;
            address token1 = deposits[tokenId].token1;
            // send collected fees to owner
            TransferHelper.safeTransfer(token0, owner, amount0);
            TransferHelper.safeTransfer(token1, owner, amount1);
      }

      function retrieveNFT(uint256 tokenId) external {
            // must be the owner of the NFT
            require(msg.sender == deposits[tokenId].owner, 'Not the owner');
            // transfer ownership to original owner
            nonfungiblePositionManager.safeTransferFrom(address(this), msg.sender, tokenId);
            //remove information related to tokenId
            delete deposits[tokenId];
      }
}