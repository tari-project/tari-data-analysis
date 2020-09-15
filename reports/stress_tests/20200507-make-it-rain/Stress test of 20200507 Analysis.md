# Test make-it-rain-20200507

## Test setup

The following command sequences were pasted into the CLI of 6 base node wallets within a time-span of 3 minutes, creating **6,000** Txs from each wallet for a total of **36,000** Txs. Each wallet had a sufficient amount of **10,000 µT** UTXOs to pay **9,000 + 1*n, n=0 .. 199 µT** and cover a basic fee of **750 µT** per Tx. The first Tx were initiated 2020-05-07 18:27:05, and the last Tx 2020-05-07 20:57:50, thus within a time span of 2.5 hours.

| #    | Command line from 'pluto win 01'                             |
| ---- | ------------------------------------------------------------ |
| 1/3  | make-it-rain 200 1 9000 1 now  b45b165f862c2874214c6f9b258bf4ddb5fd4bc52fc5c3b37fb0146827b08969  make-it-rain: from pluto win 01 to cjs77 |
| 1/3  | make-it-rain 200 1 9000 1 now  445308e7d02bb3e2a923bf908b9a2652e4397077659b591c1e4d5ff43b68ba2f  make-it-rain: from pluto win 01 to strider |
| 1/3  | make-it-rain 200 1 9000 1 now  7ebfb13511caf758c63a4af8449f0377595908665cc22955052f002f0d6d8f23  make-it-rain: from pluto win 01 to dunnock OSX |
| 1/3  | make-it-rain 200 1 9000 1 now  a6f7662a94f4669d9fa17e790d624492306161f68934e651fb6f512d4f1fcf7a  make-it-rain: from pluto win 01 to dunnock Win |
| 1/3  | make-it-rain 200 1 9000 1 now  36c70c1c31b2a117c0293346f04c1c135a0c984ffd812e3a8682c390d1014755  make-it-rain: from pluto win 01 to jay |
| 1/3  | make-it-rain 200 1 9000 1 now  92b34a4dc815531af8aeb8a1f1c8d18b927ddd7feabc706df6a1f87cf5014e54  make-it-rain: from pluto win 01 to simian |
| 1/3  | make-it-rain 200 1 9000 1 now  f4fe3fb12edd39a9f8354c7725bd386cf3767ddc42b94332b6b66e19e0efbf54  make-it-rain: from pluto win 01 to pluto Ubu 01 |
| 1/3  | make-it-rain 200 1 9000 1 now  4c51899f4eb21de2cc8f7ae253fa1937aabca56b187e47a17d1ca258e7801514  make-it-rain: from pluto win 01 to pluto Ubu 02 |
| 1/3  | make-it-rain 200 1 9000 1 now  184d842dffa0e82b13bb70229591e4b11d416fc731577f618bab0410d1878a79  make-it-rain: from pluto win 01 to blackwolfsa |
| 1/3  | make-it-rain 200 1 9000 1 now  cad184ce925b0c83549f04d5ef4d4b945be85e3d175d542c909bf1e82ab9d440  make-it-rain: from pluto win 01 to tas |
| 2/3  | make-it-rain 200 1 9000 1 now  b45b165f862c2874214c6f9b258bf4ddb5fd4bc52fc5c3b37fb0146827b08969  make-it-rain: from pluto win 01 to cjs77 |
| 2/3  | make-it-rain 200 1 9000 1 now  445308e7d02bb3e2a923bf908b9a2652e4397077659b591c1e4d5ff43b68ba2f  make-it-rain: from pluto win 01 to strider |
| 2/3  | make-it-rain 200 1 9000 1 now  7ebfb13511caf758c63a4af8449f0377595908665cc22955052f002f0d6d8f23  make-it-rain: from pluto win 01 to dunnock OSX |
| 2/3  | make-it-rain 200 1 9000 1 now  a6f7662a94f4669d9fa17e790d624492306161f68934e651fb6f512d4f1fcf7a  make-it-rain: from pluto win 01 to dunnock Win |
| 2/3  | make-it-rain 200 1 9000 1 now  36c70c1c31b2a117c0293346f04c1c135a0c984ffd812e3a8682c390d1014755  make-it-rain: from pluto win 01 to jay |
| 2/3  | make-it-rain 200 1 9000 1 now  92b34a4dc815531af8aeb8a1f1c8d18b927ddd7feabc706df6a1f87cf5014e54  make-it-rain: from pluto win 01 to simian |
| 2/3  | make-it-rain 200 1 9000 1 now  f4fe3fb12edd39a9f8354c7725bd386cf3767ddc42b94332b6b66e19e0efbf54  make-it-rain: from pluto win 01 to pluto Ubu 01 |
| 2/3  | make-it-rain 200 1 9000 1 now  4c51899f4eb21de2cc8f7ae253fa1937aabca56b187e47a17d1ca258e7801514  make-it-rain: from pluto win 01 to pluto Ubu 02 |
| 2/3  | make-it-rain 200 1 9000 1 now  184d842dffa0e82b13bb70229591e4b11d416fc731577f618bab0410d1878a79  make-it-rain: from pluto win 01 to blackwolfsa |
| 2/3  | make-it-rain 200 1 9000 1 now  cad184ce925b0c83549f04d5ef4d4b945be85e3d175d542c909bf1e82ab9d440  make-it-rain: from pluto win 01 to tas |
| 3/3  | make-it-rain 200 1 9000 1 now  b45b165f862c2874214c6f9b258bf4ddb5fd4bc52fc5c3b37fb0146827b08969  make-it-rain: from pluto win 01 to cjs77 |
| 3/3  | make-it-rain 200 1 9000 1 now  445308e7d02bb3e2a923bf908b9a2652e4397077659b591c1e4d5ff43b68ba2f  make-it-rain: from pluto win 01 to strider |
| 3/3  | make-it-rain 200 1 9000 1 now  7ebfb13511caf758c63a4af8449f0377595908665cc22955052f002f0d6d8f23  make-it-rain: from pluto win 01 to dunnock OSX |
| 3/3  | make-it-rain 200 1 9000 1 now  a6f7662a94f4669d9fa17e790d624492306161f68934e651fb6f512d4f1fcf7a  make-it-rain: from pluto win 01 to dunnock Win |
| 3/3  | make-it-rain 200 1 9000 1 now  36c70c1c31b2a117c0293346f04c1c135a0c984ffd812e3a8682c390d1014755  make-it-rain: from pluto win 01 to jay |
| 3/3  | make-it-rain 200 1 9000 1 now  92b34a4dc815531af8aeb8a1f1c8d18b927ddd7feabc706df6a1f87cf5014e54  make-it-rain: from pluto win 01 to simian |
| 3/3  | make-it-rain 200 1 9000 1 now  f4fe3fb12edd39a9f8354c7725bd386cf3767ddc42b94332b6b66e19e0efbf54  make-it-rain: from pluto win 01 to pluto Ubu 01 |
| 3/3  | make-it-rain 200 1 9000 1 now  4c51899f4eb21de2cc8f7ae253fa1937aabca56b187e47a17d1ca258e7801514  make-it-rain: from pluto win 01 to pluto Ubu 02 |
| 3/3  | make-it-rain 200 1 9000 1 now  184d842dffa0e82b13bb70229591e4b11d416fc731577f618bab0410d1878a79  make-it-rain: from pluto win 01 to blackwolfsa |
| 3/3  | make-it-rain 200 1 9000 1 now  cad184ce925b0c83549f04d5ef4d4b945be85e3d175d542c909bf1e82ab9d440  make-it-rain: from pluto win 01 to tas |

## Observations

Each Txs is sent to the network via dual paths; directly from the two participating wallets to their linked base nodes and then asynchronously via the store-and-forward (S&F) mechanism.

- The same Tx is being propagated through the network via s&F long after the original Tx have been attempted:, for example Tx `1b7dee69e5eca116b6ef8e322f8961a4ea6aa855845d736252e019f6e305b209`, has been received multiple times and it was inserted into the orphan pool multiple times.
- The same base node keeps on sending the same Txs over and over

## Measurements

| Node          | Txs submitted | Unconfirmed pool | Mined |
| ------------- | ------------- | ---------------- | ----- |
| pluto win 01  | 6000          | 1005             | 278   |
| pluto win 02  | 6000          | 1053             | 386   |
| pluto win 03  | 6000          | 1390             | 464   |
| hansie win 01 | 6000          | 4203             | 222   |
| hansie win 02 | 6000          | 3724             | 219   |
| hansie win 03 | 6000          | 3824             | 237   |
| Totals        | 36000         | 15199            | 1806  |