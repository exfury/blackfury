// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @notice Implementation of CIP-001 https://github.com/Blackfury-Improvement-Proposals/CIPs/blob/main/CIP-001.md
/// @dev Every contract is responsible to register itself in the constructor by calling `register(address)`.
///      If contract is using proxy pattern, it's possible to register retroactively, however past fees will be lost.
///      Recipient withdraws fees by calling `withdraw(uint256,address,uint256)`.
contract Turnstile is Ownable, ERC721Enumerable {
    using Counters for Counters.Counter;

    struct NftData {
        uint256 tokenId;
        bool registered;
    }

    Counters.Counter private _tokenIdTracker;

    /// @notice maps smart contract address to tokenId
    mapping(address => NftData) public feeRecipient;

    /// @notice maps tokenId to fees earned
    mapping(uint256 => uint256) public balances;

    event Register(address smartContract, address recipient, uint256 tokenId);
    event Assign(address smartContract, uint256 tokenId);
    event Withdraw(uint256 tokenId, address recipient, uint256 feeAmount);
    event DistributeFees(uint256 tokenId, uint256 feeAmount);

    error NotAnOwner();
    error NotSmartContract();
    error AlreadyRegistered();
    error Unregistered();
    error InvalidRecipient();
    error InvalidTokenId();
    error NothingToWithdraw();
    error NothingToDistribute();

    /// @dev only owner of _tokenId can call this function
    modifier onlyNftOwner(uint256 _tokenId) {
        if (ownerOf(_tokenId) != msg.sender) revert NotAnOwner();

        _;
    }

    /// @dev only smart contract that is unregistered can call this function
    modifier onlyUnregistered() {
        address smartContract = msg.sender;

        if (isRegistered(smartContract)) revert AlreadyRegistered();

        _;
    }

    constructor() ERC721("Turnstile", "Turnstile") {}

    /// @notice Returns current value of counter used to tokenId of new minted NFTs
    /// @return current counter value
    function currentCounterId() external view returns (uint256) {
        return _tokenIdTracker.current();
    }

    /// @notice Returns tokenId that collects fees generated by the smart contract
    /// @param _smartContract address of the smart contract
    /// @return tokenId that collects fees generated by the smart contract
    function getTokenId(address _smartContract) external view returns (uint256) {
        if (!isRegistered(_smartContract)) revert Unregistered();

        return feeRecipient[_smartContract].tokenId;
    }

    /// @notice Returns true if smart contract is registered to collect fees
    /// @param _smartContract address of the smart contract
    /// @return true if smart contract is registered to collect fees, false otherwise
    function isRegistered(address _smartContract) public view returns (bool) {
        return feeRecipient[_smartContract].registered;
    }

    /// @notice Mints ownership NFT that allows the owner to collect fees earned by the smart contract.
    ///         `msg.sender` is assumed to be a smart contract that earns fees. Only smart contract itself
    ///         can register a fee receipient.
    /// @param _recipient recipient of the ownership NFT
    /// @return tokenId of the ownership NFT that collects fees
    function register(address _recipient) public onlyUnregistered returns (uint256 tokenId) {
        address smartContract = msg.sender;

        if (_recipient == address(0)) revert InvalidRecipient();

        tokenId = _tokenIdTracker.current();
        _mint(_recipient, tokenId);
        _tokenIdTracker.increment();

        emit Register(smartContract, _recipient, tokenId);

        feeRecipient[smartContract] = NftData({
            tokenId: tokenId,
            registered: true
        });
    }

    /// @notice Assigns smart contract to existing NFT. That NFT will collect fees generated by the smart contract.
    ///         Callable only by smart contract itself.
    /// @param _tokenId tokenId which will collect fees
    /// @return tokenId of the ownership NFT that collects fees
    function assign(uint256 _tokenId) public onlyUnregistered returns (uint256) {
        address smartContract = msg.sender;

        if (!_exists(_tokenId)) revert InvalidTokenId();

        emit Assign(smartContract, _tokenId);

        feeRecipient[smartContract] = NftData({
            tokenId: _tokenId,
            registered: true
        });

        return _tokenId;
    }

    /// @notice Withdraws earned fees to `_recipient` address. Only callable by NFT owner.
    /// @param _tokenId token Id
    /// @param _recipient recipient of fees
    /// @param _amount amount of fees to withdraw
    /// @return amount of fees withdrawn
    function withdraw(uint256 _tokenId, address payable _recipient, uint256 _amount)
        public
        onlyNftOwner(_tokenId)
        returns (uint256)
    {
        uint256 earnedFees = balances[_tokenId];

        if (earnedFees == 0 || _amount == 0) revert NothingToWithdraw();
        if (_amount > earnedFees) _amount = earnedFees;

        balances[_tokenId] = earnedFees - _amount;

        emit Withdraw(_tokenId, _recipient, _amount);

        Address.sendValue(_recipient, _amount);

        return _amount;
    }

    /// @notice Distributes collected fees to the smart contract. Only callable by owner.
    /// @param _tokenId NFT that earned fees
    function distributeFees(uint256 _tokenId) public onlyOwner payable {
        if (msg.value == 0) revert NothingToDistribute();

        balances[_tokenId] += msg.value;
        emit DistributeFees(_tokenId, msg.value);
    }
}