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