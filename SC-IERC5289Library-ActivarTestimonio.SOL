pragma solidity ^0.8.0;

import "./IERC5289Library.sol";

contract NotaryTestimony is IERC5289Library {
    struct Testimony {
        string ipfsHash;
        string securityPaperQR;
        string testimonyQR;
        uint256 protocolNumber;
        uint256 protocolDate;
        address notary;
        address generator;
        uint64 timestamp;
        bool signed;
    }

    mapping(uint16 => Testimony) public testimonies;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC5289Library).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function activateTestimony(
        uint16 documentId,
        string memory ipfsHash,
        string memory securityPaperQR,
        string memory testimonyQR,
        uint256 protocolNumber,
        uint256 protocolDate
    ) external {
        testimonies[documentId] = Testimony(
            ipfsHash,
            securityPaperQR,
            testimonyQR,
            protocolNumber,
            protocolDate,
            msg.sender,
            tx.origin,
            uint64(block.timestamp),
            true
        );
        emit DocumentSigned(msg.sender, documentId);
    }

    function documentSignedAt(address user, uint16 documentId) external view override returns (uint64 timestamp) {
        if (testimonies[documentId].notary == user) {
            return testimonies[documentId].timestamp;
        }
        return 0;
    }

    function legalDocument(uint16 documentId) external view override returns (string memory ipfsLink) {
        return testimonies[documentId].ipfsHash;
    }

    function documentSigned(address user, uint16 documentId) external view override returns (bool signed) {
        return testimonies[documentId].notary == user && testimonies[documentId].signed;
    }

    function signDocument(address signer, uint16 documentId) external override {
        require(signer == msg.sender, "Only signer can sign");
        require(!testimonies[documentId].signed, "Document already signed");
        
        testimonies[documentId].notary = signer;
        testimonies[documentId].timestamp = uint64(block.timestamp);
        testimonies[documentId].signed = true;
        
        emit DocumentSigned(signer, documentId);
    }
}