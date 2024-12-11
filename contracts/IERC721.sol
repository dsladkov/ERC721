// SPDX-License-Identifier: MIT
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