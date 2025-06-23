// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BlogNFT is ERC721URIStorage, Ownable {
    uint256 public nextPostId;

    struct Post {
        string metadataURI;
        bool exists;
    }

    // postId => Post
    mapping(uint256 => Post) public posts;

    //postId => user => hasMinted
    mapping(uint256 => mapping(address => bool)) public hasMinted;

    // postId => number of claims
    mapping(uint256 => uint256) public claimsPerPost;

    // tokenId for minted NFTs
    uint256 public nextTokenId;

    event BlogPostCreated(uint256 indexed postId, string metadataURI);
    event BlogPostClaimed(address indexed user, uint256 indexed postId, uint256 tokenId);

    constructor() ERC721("BlogPostAccessNFT", "BLOG") Ownable(msg.sender) {}

    // Owner can create a new blog post
    function createPost(string memory metadataURI) external onlyOwner {
        posts[nextPostId] = Post({
            metadataURI: metadataURI,
            exists: true
        });

        emit BlogPostCreated(nextPostId, metadataURI);
        nextPostId++;
    }

    function getAllPosts() external view returns (Post[] memory) {
        Post[] memory allPosts = new Post[](nextPostId);
        for (uint256 i = 0; i < nextPostId; i++) {
            allPosts[i] = posts[i];
        }
        return allPosts;
    }

    // Users can claim a blog post NFT if they haven't already
    function claimPost(uint256 postId) external {
        require(posts[postId].exists, "Post not minted");
        require(!hasMinted[postId][msg.sender], "Already claimed");

        uint256 tokenId = nextTokenId;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, posts[postId].metadataURI);

        hasMinted[postId][msg.sender] = true;
        claimsPerPost[postId]++;
        nextTokenId++;

        emit BlogPostClaimed(msg.sender, postId, tokenId);
    }

    // Check if a user has claimed a specific post
    function hasClaimed(address user, uint256 postId) external view returns (bool) {
        return hasMinted[postId][user];
    }

    function getClaimsForPost(uint256 postId) external view returns (uint256) {
        return claimsPerPost[postId];
    }
}