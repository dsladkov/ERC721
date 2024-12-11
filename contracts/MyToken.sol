// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";

contract MyToken is ERC721, ERC721URIStorage, ERC721Enumerable { //ERC721Enumerable
  address public owner;
  uint currentTokenId;


  constructor() ERC721("MyToken", "MTK") {
    owner = msg.sender;
  }

  function safeMint(address to, string calldata tokenId) public {
    require(owner == msg.sender, "Not an owner");

    _safeMint(to, currentTokenId);
    _setTokenURI(currentTokenId, tokenId);

    currentTokenId++;
  }

  function supportInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns(bool) {
    return super.supportInterface(interfaceId);
  }
  
  function _baseURI() internal pure virtual override returns(string memory) {
    return "ipfs://";
  }

  function _burn(uint tokenId) internal override (ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function tokenURI(uint tokenId) public view virtual override(ERC721, ERC721URIStorage) requireMinted(tokenId) returns(string memory) {
    return super.tokenURI(tokenId);
  }


  function _beforeTokenTransfer(address from, address to, uint tokenId) internal virtual override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function _afterTokenTransfer(address from, address to, uint tokenId) internal virtual override(ERC721, ERC721Enumerable) {
    super._afterTokenTransfer(from, to, tokenId);
  }
}

