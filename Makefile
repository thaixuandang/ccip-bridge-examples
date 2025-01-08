include .env

1-prepare-on-base-sepolia:
	@echo "Prepare on Base Sepolia network"
	@forge script PrepareOnSourceBlockchain -f base-sepolia --private-key $(PRIVATE_KEY) --verify --broadcast

2-setup-on-ronin-saigon:
	@echo "Setup on Ronin Saigon network"
	@FOUNDRY_PROFILE=ronin forge script SetupOnDestinationBlockchain -f ronin-saigon --private-key $(PRIVATE_KEY) --verify --verifier sourcify --verifier-url https://sourcify.roninchain.com/server/ --legacy --broadcast

3-token-owner-action-on-base-sepolia:
	@echo "Token owner action on Base Sepolia network"
	@forge script TokenOwnerActionOnSourceBlockchain -f base-sepolia --private-key $(PRIVATE_KEY_OF_TOKEN_OWNER) --broadcast

4-finalize-setup-on-base-sepolia:
	@echo "Finalize setup on Base Sepolia network"
	@forge script FinalizeSetupOnSourceBlockchain -f base-sepolia --private-key $(PRIVATE_KEY) --broadcast


1-prepare-on-base:
	@echo "Prepare on Base network"
	@forge script PrepareOnSourceBlockchain -f base --private-key $(PRIVATE_KEY) --verify --broadcast

2-setup-on-ronin:
	@echo "Setup on Ronin network"
	@FOUNDRY_PROFILE=ronin forge script SetupOnDestinationBlockchain -f ronin --private-key $(PRIVATE_KEY) --verify --verifier sourcify --verifier-url https://sourcify.roninchain.com/server/ --legacy --broadcast

3-token-owner-action-on-base:
	@echo "Token owner action on Base network"
	@forge script TokenOwnerActionOnSourceBlockchain -f base --private-key $(PRIVATE_KEY_OF_TOKEN_OWNER) --broadcast

4-finalize-setup-on-base:
	@echo "Finalize setup on Base network"
	@forge script FinalizeSetupOnSourceBlockchain -f base --private-key $(PRIVATE_KEY) --broadcast