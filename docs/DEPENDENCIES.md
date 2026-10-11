# Dependency maintenance

The dependency audit on 2026-10-11 uses stable upstream tags:

| Package | Version |
| --- | --- |
| Apollo iOS and Apollo CLI | 2.4.0 |
| CodeScanner | 2.5.2 |
| KeychainSwift | 24.0.0 |
| MessagePacker | 0.4.7 |

The generated schema package pins Apollo to exactly 2.4.0. Apollo 2.4 requires Swift 6.1 or newer; the schema package follows its platform minimums. The app's existing deployment settings are retained, and the unit-test target uses the same minimum iOS version as the app.

`apollo-ios-cli` installs the pinned official release into `.build/apollo-cli/2.4.0`, verifies the archive's SHA-256, and reuses the local executable. It does not require a global installation. Set `APOLLO_CLI_CACHE_DIR` to use another cache directory.

Generate from the committed schema snapshot:

```sh
./apollo-ios-cli generate --path Shared/api/apollo-codegen-config.json
```

Add `--fetch-schema` only when the configured local backend is running and an intentional schema refresh is required. Updating SDKs does not require changing the GraphQL schema or operations.

Build and run the unit suite through the dedicated shared test scheme:

```sh
xcodebuild -workspace TeaElephant.xcworkspace -scheme TeaElephantTests \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' test
```

Choose an installed simulator when using a different Xcode version. UI tests use the existing separate target and are not included in this unit-test scheme.

The Apollo 2 adapters preserve cache-first, network-only, and cache-and-network fetching. Cancelling their tasks terminates the underlying requests or subscriptions. HTTP auth uses the existing synchronized Keychain token; WebSocket auth travels in `connection_init`. GraphQL errors are not written to the cache, and cached responses do not change authentication state.
