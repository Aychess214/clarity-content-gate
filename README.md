# Content Gate

A token-gated content access system built on the Stacks blockchain.

## Overview

This smart contract implements a content access control system where:

- Content creators can publish content with unique IDs and prices
- Access to content requires holding a minimum number of tokens
- Users can purchase access rights to specific content
- All access rights and content metadata are stored on-chain

## Features

- Content publishing with hash verification
- Token-gated access control
- Configurable minimum token requirements
- Access rights management
- Content activation/deactivation

## Contract Functions

- `publish-content`: Publish new content with hash and price
- `purchase-access`: Purchase access rights to content
- `can-access-content`: Check if user has access to content
- `get-content`: Get content metadata
- `update-min-tokens`: Update minimum token requirement
