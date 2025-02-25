# Dash Mon[k]ey
> Contracts repo




### Main logic

- Node calls `Recipe.run()`
  - determines token to trade
  - Runs loop over all minted tokens
    - Computes amount
    - `Recipe.run()` calls `Monkey.execute()`
      - Verifies caller and active status
      - Transfers token to `Recipe`
        - `Monkey.execute()` calls `Recipe.execute()`
          - Makes the trade
          - Computes and transfers fees
          - Transfers token to `Monkey`