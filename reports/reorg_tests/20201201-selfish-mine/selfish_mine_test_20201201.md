# Selfish mining attacks

We set up some selfish mining attacks using Monero merged mining with XMRig (RandomX difficulty algorithm) and the Tari 
Merge Mining Proxy. This was successfully carried out on three separate occasions and many blocks could be selfishly 
mined. Each time the competing chain was introduced to the rest of the Tari Ridcully testnet network, the resulting 
reorg happened smoothly in all nodes that were monitored.

After syncing to the best height at the time, the Tari Base Node and Tari Console Wallet were isolated from the Tari 
Ridcully testnet network by giving them new Tor identities and removing all knowledge of any peers from their respective 
databases. After that, the XMRig miner was started and this allowed the attacking blockchain to selfishly mine blocks at 
a fairly good pace. With the two difficulty algorithms competing fairly, the first block in is usually chosen, with 
small reorgs of ~2 to 3 blocks occurring from time to time. Due to the majority of the blocks currently being mined with 
SHA3, any change in accumulated difficulty for RandomX (using XMRig) mined blocks will have an advantage when the 
geometric mean of accumulated difficulties is calculated. This is enhanced by consensus settings favouring RandomX mined 
blocks in a 60:40 ratio. 

Selfish mining started at 2020-11-30 23:25:32 SAST (21:25:32 UCT), and the first attack was launched at 2020-12-01 
11:10:02 SAST (09:10:02 UCT), winning a total of **204 selfishly mined blocks**. After the first successful attack, 
selfish mining was continued, with the final two attacks on 2020-12-07 09:08:02  (11:08:022 UCT) and 2020-12-08 09:11:52 
(11:11:52 UCT) respectively. In the end a total of **1760 selfishly mined blocks** were won.

In summary:

- A majority RandomX hash rate will always be able to outpace SHA3 miners and perform selfish mining
- The Tari Ridcully testnet network were able to handle these massive reorgs seamlessly.
- Belated apologies for all those Tari supporters that lost tXTR because of this very important network test.