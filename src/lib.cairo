#[starknet::contract]
mod MyNFT {
    use openzeppelin::token::erc721::interface::IERC721;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;
    use openzeppelin::token::erc721::ERC721Component::Errors;
    use starknet::ContractAddress;

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);


    // NOTE: I've implemented metadata traits manually to support token URIs with the type `Array<felt252>`.

    // #[abi(embed_v0)]
    // impl ERC721MetadataImpl = ERC721Component::ERC721MetadataImpl<ContractState>;

    // #[abi(embed_v0)]
    // impl ERC721MetadataCamelOnly =
    // ERC721Component::ERC721MetadataCamelOnlyImpl<ContractState>;

    // ERC721
    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;


    #[abi(embed_v0)]
    impl ERC721CamelOnly = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // SRC5
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, recipient: ContractAddress) {
        let name = 'Coin Flip';
        let symbol = 'FLIP';
        self.erc721.initializer(name, symbol);
    }


    #[starknet::interface]
    trait IERC721MetadataFeltArray<TState> {
        fn name(self: @TState) -> felt252;
        fn symbol(self: @TState) -> felt252;
        fn token_uri(self: @TState, token_id: u256) -> Array<felt252>;
    }

    #[starknet::interface]
    trait IERC721MetadataFeltArrayCamelOnly<TState> {
        fn tokenURI(self: @TState, tokenId: u256) -> Array<felt252>;
    }

    #[external(v0)]
    impl ERC721MetadataImpl of IERC721MetadataFeltArray<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.erc721.ERC721_name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.erc721.ERC721_symbol.read()
        }

        fn token_uri(self: @ContractState, token_id: u256) -> Array<felt252> {
            self._token_uri(token_id)
        }
    }


    #[external(v0)]
    impl ERC721MetadataCamelOnlyImpl of IERC721MetadataFeltArrayCamelOnly<ContractState> {
        fn tokenURI(self: @ContractState, tokenId: u256) -> Array<felt252> {
            self._token_uri(tokenId)
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _token_uri(self: @ContractState, token_id: u256) -> Array<felt252> {
            assert(self.erc721._exists(token_id), Errors::INVALID_TOKEN_ID);

            let mut content = ArrayTrait::<felt252>::new();

            content.append('data:application/json;utf8,{\"na');
            content.append('me\":\"Coin Flip\",\"description\":\"');
            content.append('You won this NFT by flipping a ');
            content.append('coin.\",\"image\":\"data:image/svg+');
            content.append('xml,%3Csvg xmlns=\"http://www.w3');
            content.append('.org/2000/svg\" viewBox=\"0 0 128');
            content.append(' 128\" width=\"512\" height=\"512\" ');
            content.append('fill=\"none\"%3E%3Cpath d=\"M0 0h1');
            content.append('28v128H0z\" fill=\"%23232529\"/%3E');
            content.append('%3Crect x=\"16\" width=\"96\" heigh');
            content.append('t=\"96\" rx=\"64\" y=\"16\" paint-ord');
            content.append('er=\"fill\" fill=\"%23ffba1c\"/%3E%');
            content.append('3Ctext style=\"white-space:pre\" ');
            content.append('x=\"34.787\" y=\"67.1\" fill=\"%2323');
            content.append('2529\" font-size=\"15\"%3EYou won!');
            content.append('%3C/text%3E%3C/svg%3E\",\"attribu');
            content.append('tes\":[{\"trait_type\":\"Luck\",\"val');
            content.append('ue\":\"Very Lucky\"}]}');

            content
        }
    }
}
