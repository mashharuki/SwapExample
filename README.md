# SwapExample
UniSwapの様なDEXアプリを作成するためのリポジトリです。

## Uniswap
  世界的に有名なDEXのこと。  
  AMM形式を取り入れた交換所で、管理者不在となっている。

### エラーコード
  CompilerError: Stack too deep when compiling inline assembly: Variable headStart is 1 slot(s) too deep inside the stack.  

  ⇨ 一つのコントラクトの中に変数を使いすぎると発生するエラー

  今回の場合は、下記ソースが原因
  ```sol

       (, , address token0, address token1, , , , uint128 liquidity, , , , ) = 
                  nonfungiblePositionManager.positions(tokenId);
  ```

  ↑ 12個の変数を一度に受け取ろうとしているため発生している。

### プールインスタンスを作成した際の実行結果
 ```json
    {
      factory: '0x1F98431c8aD98523631AE4a59f267346ea31F984',
      token0: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
      token1: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
      fee: 3000,
      tickSpacing: 60,
      maxLiquidityPerTick: BigNumber {
        _hex: '0x023746e6a58dcb13d4af821b93f062',
        _isBigNumber: true
      }
    }
 ```

 ### createTradeの実行に成功した時の実行結果
  ```json
    The quoted amount out is 530557213437
    The unchecked trade object is Trade {
      swaps: [
        {
          inputAmount: [CurrencyAmount],
          outputAmount: [CurrencyAmount],
          route: [Route]
        }
      ],
      tradeType: 0
    }
  ```