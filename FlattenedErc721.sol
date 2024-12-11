// Sources flattened with hardhat v2.22.17 https://hardhat.org

// SPDX-License-Identifier: MIT

// File contracts/IERC165.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IERC165 {
  function supportInterface(bytes4 interfaceId) external view returns(bool);
}


// File contracts/ERC165.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

contract ERC165 is IERC165 {
  function supportInterface(bytes4 interfaceId) public view virtual returns(bool) {
    return interfaceId == type(IERC165).interfaceId;
  }
}


// File contracts/IERC721.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  // how many nft's tokens current address has
  function balanceOf(address owner) external view returns(uint);

  // get address who owns the nft token
  function ownerOf(uint tokenId) external view returns(address);

  // safe transfer (check does accepting contract supports nft tokens)
  function safeTransferFrom(address from, address to, uint tokenId, bytes calldata data) external;
  function safeTransferFrom(address from, address to, uint tokenId) external;

  // unsafe transfer
  function transferFrom(address from, address to, uint tokenId) external;

  function approve(address to, uint tokenId) external;
  function setApprovalForAll(address operator, bool approved) external;

  function getApproved(uint tokenId) external view returns(address);
  function isApprovedForAll(address owner, address operator) external view returns(bool);
}


// File contracts/IERC721Metadata.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {
   function name() external view returns(string memory);

   function symbol() external view returns(string memory);
   
   function tokenURI(uint tokenId) external view returns(string memory);
}


// File contracts/IERC721Receiver.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721Receiver {
  function onERC721Received(address operator, address from, uint tokenId, bytes calldata data) external returns(bytes4);
}


// File contracts/Strings.sol

// Original license: SPDX_License_Identifier: MIT
//taken from OpenZeppelin
pragma solidity ^0.8.0;

library Strings {
  function toString(uint256 value) internal pure returns(string memory) {
    if(value == 0) {
      return "0";
    }

    uint256 temp = value;
    uint256 digits;

    while(temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while(value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }
}


// File contracts/ERC721.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;





contract ERC721 is ERC165, IERC721, IERC721Metadata {
  using Strings for uint;
  string private _name;
  string private _symbol;

  mapping(address _owner => uint _amount) private _balances;
  mapping(uint _tokenId => address _owner) private _owners;
  mapping(uint _tokenId => address _approved) private _tokenApprovals;
  mapping(address _owner => mapping(address _operator => bool _isApproved)) private _operatorApprovals; 

  modifier requireMinted(uint tokenId) {
    require(_exists(tokenId), "not minted");
    _;
  }

  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
  }

  function transferFrom(address from, address to, uint tokenId) public {
    require(_isApprovedOrOwner(msg.sender, tokenId), "not approved or owner!");
    _transfer(from, to, tokenId);
    emit Transfer(from, to, tokenId);
  }

  function safeTransferFrom(address from, address to, uint tokenId) public {
    safeTransferFrom(from, to, tokenId, "");
  }

  function safeTransferFrom(address from, address to, uint tokenId, bytes memory data) public {
    require(_isApprovedOrOwner(msg.sender, tokenId), "not an owner!");
    _safeTransfer(from, to, tokenId, data);
  }

  function name() external view returns(string memory) {
    return _name;
  }

  function symbol() external view returns(string memory) {
    return _symbol;
  }

  function balanceOf(address owner) public view returns(uint) {
    require(owner != address(0), "Owner cannot be zero");
    return _balances[owner];
  }

  function _safeMint(address to, uint tokenId) internal virtual {
    _safeMint(to, tokenId, "");
  }

  function _safeMint(address to, uint tokenId, bytes memory data) internal virtual {
    _mint(to, tokenId);
    require(_checkOnERC721Received(address(0), to, tokenId, data), "non-erc721 receiver");
  }

  function _mint(address to, uint tokenId) internal virtual {
    require(to != address(0), "zero address to");
    require(!_exists(tokenId), "this tokenId is already minted");

    _beforeTokenTransfer(address(0), to, tokenId);

    _owners[tokenId] = to;
    _balances[to]++;
    emit Transfer(address(0), to, tokenId);

    _afterTokenTransfer(address(0), to, tokenId);
  }

  function burn(uint256 tokenId) public virtual {
    require(_isApprovedOrOwner(msg.sender, tokenId), "not an owner!");
    _burn(tokenId);
  }

  function _burn(uint tokenId) internal virtual {
    address owner = ownerOf(tokenId);
    _beforeTokenTransfer(owner, address(0), tokenId);

    delete _tokenApprovals[tokenId];
    _balances[owner]--;
    delete _owners[tokenId];
    emit Transfer(owner, address(0), tokenId);

    _afterTokenTransfer(owner, address(0), tokenId);

  }

  function _baseURI() internal pure virtual returns(string memory) {
    return ""; //"ipfs://"
  }

  function ownerOf(uint tokenId) public view requireMinted(tokenId) returns(address) {
    return _owners[tokenId];
  }

  function approve(address to, uint tokenId) public {
    address _owner = ownerOf(tokenId);
    require(_owner == msg.sender || isApprovedForAll(_owner, msg.sender), "Not an owner");

    require(to != _owner, "Cannot approve to yourself");

    _tokenApprovals[tokenId] = to;

    emit Approval(_owner, to, tokenId);
  }

  function setApprovalForAll(address operator, bool approved) public {
    require(msg.sender != operator, "Cannot approve to self");
    _operatorApprovals[msg.sender][operator] = approved;

    emit ApprovalForAll(msg.sender, operator, approved);
  }

  function getApproved(uint tokenId) public view requireMinted(tokenId) returns(address) {
    return _tokenApprovals[tokenId];
  }

  function isApprovedForAll(address owner, address operator) public view returns(bool) {
    require(owner != address(0) && operator != address(0), "Ivalid addresses");
    return _operatorApprovals[owner][operator];
  }

  function supportInterface(bytes4 interfaceId) public view virtual override returns(bool) {
    return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId ||
    super.supportInterface(interfaceId);
  }

  // tokenId = 1234
  // ipfs://1234
  // example.com/nft/1234
  function tokenURI(uint tokenId) public view virtual requireMinted(tokenId) returns(string memory) {

    string memory baseURI =  _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : ""; //Strings.toString(tokenId)
  }

  function _exists(uint tokenId) internal view returns(bool) {
    return _owners[tokenId] != address(0);
  }

  function _isApprovedOrOwner(address spender, uint tokenId) internal view returns(bool) {
    address owner = ownerOf(tokenId);
    return(spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
  }

   function _safeTransfer(address from, address to, uint tokenId, bytes memory data) internal {
    _transfer(from, to, tokenId);
    require(_checkOnERC721Received(from, to, tokenId, data), "transfer to non-erc721 receiver");
   }

   function _checkOnERC721Received(address from, address to, uint tokenId, bytes memory data) private returns(bool) {
    if(to.code.length > 0) {
      try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns(bytes4 retval) {
        return retval == IERC721Receiver.onERC721Received.selector;
      } catch (bytes memory reason) {
        if(reason.length == 0) {
          revert("Transfer to non-erc721 receiver");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    } else {
      return true;
    }
   }

  function _transfer(address from, address to, uint tokenId) internal {
    require(ownerOf(tokenId) == from, "incorect owner");
    require(to != address(0), "to address is zero");

    _beforeTokenTransfer(from, to, tokenId);

    delete _tokenApprovals[tokenId];

    
    _balances[from]--;
    _balances[to]++;
    _owners[tokenId] = to;

    emit Transfer(from, to, tokenId);

    _afterTokenTransfer(from, to, tokenId);
  }

  function _beforeTokenTransfer(address from, address to, uint tokenId) internal virtual {}

  function _afterTokenTransfer(address from, address to, uint tokenId) internal virtual {}
}


// File contracts/IERC721Enumerable.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721Enumerable is IERC721 {
  function totalSupply() external view returns(uint);
  function tokenOfOwnerByIndex(address owner, uint index) external view returns(uint);
  function tokenByIndex(uint index) external view returns(uint);
  
}


// File contracts/ERC721Enumerable.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {

  uint[] private _allTokens;
  mapping(address _owner => mapping(uint _index => uint _tokenId)) private _ownedTokens;
  mapping(uint _tokenId => uint _index) private _allTokensIndex;
  mapping(uint _tokenId => uint _index) private _ownedTokensIndex;

  function totalSupply() public view returns(uint) {
    return _allTokens.length;
  }

  function tokenByIndex(uint index) public view  returns(uint) {
    require(index < _allTokens.length, "out of bonds"); // check index inside of array bonds

    return _allTokens[index];
  }

  function tokenOfOwnerByIndex(address owner, uint index) public view returns(uint) {
    require(index < balanceOf(owner), "out of bonds"); // check index inside of arays bonds

    return _ownedTokens[owner][index];
  }

  function supportInterface(bytes4 interfaceId) public view virtual override(ERC721) returns(bool) {
    return interfaceId == type(IERC721Enumerable).interfaceId ||
    super.supportInterface(interfaceId);
  }

  function _beforeTokenTransfer(address from, address to, uint tokenId) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId);

    if(from == address(0)) {
      _addTokenToAllTokensEnumeration(tokenId);
    } else if(from != to) {
      _removeTokenFromOwnerEnumeration(from, tokenId);
    }
    if(to == address(0)) {
      _removeTokenFromAllTokensEnumeration(tokenId);
    } else if (to != from) {
      _addTokenToOwnerEnumeration(to, tokenId);
    }
  }
  
  function _afterTokenTransfer(address from, address to, uint tokenId) internal virtual override {
    super._afterTokenTransfer(from, to, tokenId);
  }
  
  function _addTokenToAllTokensEnumeration(uint tokenId) private {
    _allTokensIndex[tokenId] = _allTokens.length;
    _allTokens.push(tokenId);
  }

  function _removeTokenFromAllTokensEnumeration(uint tokenId) private {
    uint lastTokenIndex = _allTokens.length - 1; // get last index
    uint tokenIndex = _allTokensIndex[tokenId]; //get index of token for delete

    uint lastTokenId = _allTokens[lastTokenIndex]; // get last tokenId for move insted of deleted token
   
    _allTokens[tokenIndex] = lastTokenId;
    _allTokensIndex[lastTokenId] = tokenIndex;

    delete _allTokensIndex[tokenId];
    _allTokens.pop(); // delete moved token from the last psotion.
  }

  function _addTokenToOwnerEnumeration(address to, uint tokenId) private {
    uint _length = balanceOf(to);

    _ownedTokensIndex[tokenId] = _length;
    _ownedTokens[to][_length] = tokenId;
  }

  function _removeTokenFromOwnerEnumeration(address from, uint tokenId) private {
    uint lastTokenIndex = balanceOf(from) - 1;
    uint tokenIndex = _ownedTokensIndex[tokenId];

    if(tokenIndex != lastTokenIndex) {
      uint lastTokenId = _ownedTokens[from][lastTokenIndex];
      _ownedTokens[from][tokenIndex] = lastTokenId;
      _ownedTokensIndex[lastTokenId] = tokenIndex;
    }

    delete _ownedTokensIndex[tokenId];
    delete _ownedTokens[from][lastTokenIndex];

  }
}


// File contracts/ERC721URIStorage.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ERC721URIStorage is ERC721 {
  mapping(uint tokenId => string tokenURI) private _tokenURIs;
  
  function _setTokenURI(uint tokenId, string memory _tokenURI) internal virtual requireMinted(tokenId) {
    _tokenURIs[tokenId] = _tokenURI;
  }

  function tokenURI(uint tokenId) public view virtual override requireMinted(tokenId) returns(string memory) {

  string memory _tokenURI = _tokenURIs[tokenId];
  string memory base =  _baseURI();

  if(bytes(base).length == 0) {
    return _tokenURI;
  }

  if (bytes(base).length > 0) {
    return string(abi.encodePacked(base, _tokenURI));
  }
  return super.tokenURI(tokenId);
  //return bytes(base.length) > 0 ? string(abi.encodePacked(base, _tokenURI)) : tokenURI;
  }

  function _burn(uint tokenId) internal virtual override {
    super._burn(tokenId);

    if(bytes(_tokenURIs[tokenId]).length != 0) {
      delete _tokenURIs[tokenId];
    }
  }
}


// File contracts/MyToken.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;



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
