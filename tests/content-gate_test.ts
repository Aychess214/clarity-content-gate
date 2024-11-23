import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure can publish and access content correctly",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const user1 = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('content-gate', 'publish-content', [
                types.uint(1),
                types.ascii("contenthash123"),
                types.uint(10)
            ], deployer.address),
        ]);
        
        block.receipts[0].result.expectOk();
        
        // Check content exists
        let contentCheck = chain.callReadOnlyFn(
            'content-gate',
            'get-content',
            [types.uint(1)],
            deployer.address
        );
        
        contentCheck.result.expectOk().expectSome();
    },
});

Clarinet.test({
    name: "Cannot publish duplicate content",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('content-gate', 'publish-content', [
                types.uint(1),
                types.ascii("contenthash123"),
                types.uint(10)
            ], deployer.address),
            Tx.contractCall('content-gate', 'publish-content', [
                types.uint(1),
                types.ascii("contenthash456"),
                types.uint(20)
            ], deployer.address),
        ]);
        
        block.receipts[0].result.expectOk();
        block.receipts[1].result.expectErr(types.uint(102)); // ERR_ALREADY_PUBLISHED
    },
});

Clarinet.test({
    name: "Purchase access requires minimum tokens",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const user1 = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('content-gate', 'purchase-access', [
                types.uint(1)
            ], user1.address)
        ]);
        
        block.receipts[0].result.expectErr(types.uint(103)); // ERR_INSUFFICIENT_TOKENS
    },
});
