// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PriceFeedConsumer} from "./interface/PriceFeed.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract NFT204 is ERC721, Ownable {
    /// @dev state variables
    uint256 price;
    uint256 totalSupply;
    uint256 sold;
    address entrepreneur;
    uint256 timestamp;
    string baseURI;

    /// @dev tokens prices contract
    PriceFeedConsumer public PricesContract;

    address public feeAddress;
    /// @dev fee percentage
    uint256 public constant FEE_PERCENTAGE = 7;

    IERC20 private ERC20Usdt;
    IERC20 private ERC20WBTC;
    IERC20 private ERC20WETH;

    /// @dev events
    event NftMinted(address requester, string token);

    /// @dev constructor
    constructor(
        uint256 _price,
        uint256 _totalSupply,
        string memory _URI,
        address _feeAddress
    ) Ownable(msg.sender) ERC721("NFT204", "204") {
        price = _price;
        totalSupply = _totalSupply;
        sold = 0;
        feeAddress = _feeAddress;
        entrepreneur = msg.sender;
        baseURI = _URI;
        ERC20Usdt = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
        ERC20WBTC = IERC20(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6);
        ERC20WETH = IERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);
        PricesContract = PriceFeedConsumer(
            0x30F396A426036dA0b2346185d3c1a19D78f86F13
        );
    }

    ////@dev mint functions

    /// @dev mint with USDT
    function mintUSDT(uint256 _quantity, address _to) external {
        uint256 amountInMatic = priceInUSDT(_quantity);

        require(
            ERC20Usdt.allowance(msg.sender, address(this)) >= amountInMatic,
            "You must approve ERC20 to the contract first"
        );
        require(
            ERC20Usdt.balanceOf(msg.sender) >= amountInMatic,
            "Not enough money"
        );
        require(sold + _quantity <= totalSupply, "There are not so many nfts");

        ///transfer ERC20
        bool transferSuccessful = ERC20Usdt.transferFrom(
            msg.sender,
            address(this),
            amountInMatic
        );

        require(transferSuccessful, "ERC20 transfer failed"); // check if the transfer was successful or not and revert if it failed

        for (uint256 i = 0; i < _quantity; i++) {
            sold += 1;
            _mint(_to, sold);
        }
        emit NftMinted(msg.sender, "USDT");
        sold += _quantity;
    }

    /// @dev mint with WBTC
    function mintWBTC(uint256 _quantity, address _to) external {
        uint256 amountInBTC = priceInBTC(_quantity);

        require(
            ERC20WBTC.allowance(msg.sender, address(this)) >= amountInBTC,
            "You must approve ERC20 to the contract first"
        );
        require(
            ERC20WBTC.balanceOf(msg.sender) >= amountInBTC,
            "Not enough money"
        );
        require(sold + _quantity <= totalSupply, "There are not so many nfts");

        /// transfer ERC20
        bool transferSuccessful = ERC20WBTC.transferFrom(
            msg.sender,
            address(this),
            amountInBTC
        );

        require(transferSuccessful, "ERC20 transfer failed"); // check if the transfer was successful or not and revert if it failed

        for (uint256 i = 0; i < _quantity; i++) {
            sold += 1;
            _mint(_to, sold);
        }
        emit NftMinted(msg.sender, "WBTC");
        sold += _quantity;
    }

    /// @dev mint with WETH
    function mintWETH(uint256 _quantity, address _to) external {
        uint256 amountInETH = priceInETH(_quantity);

        require(
            ERC20WETH.allowance(msg.sender, address(this)) >= amountInETH,
            "You must approve ERC20 to the contract first"
        );
        require(
            ERC20WETH.balanceOf(msg.sender) >= amountInETH,
            "Not enough money"
        );
        require(sold + _quantity <= totalSupply, "There are not so many nfts");

        ///transfer ERC20
        bool transferSuccessful = ERC20WETH.transferFrom(
            msg.sender,
            address(this),
            amountInETH
        );

        require(transferSuccessful, "ERC20 transfer failed"); // check if the transfer was successful or not and revert if it failed

        for (uint256 i = 0; i < _quantity; i++) {
            sold += 1;
            _mint(_to, sold);
        }
        emit NftMinted(msg.sender, "WETH");
        sold += _quantity;
    }

    /// @dev mint with MATIC
    function mint(uint256 _quantity, address _to) external payable {
        uint256 amountInMatic = priceInMatic(_quantity);
        require(msg.value >= amountInMatic, "Not enough money");
        require(sold + _quantity <= totalSupply, "There are not so many nfts");

        for (uint256 i = 0; i < _quantity; i++) {
            sold += 1;
            _mint(_to, sold);
        }

        emit NftMinted(msg.sender, "MATIC");
    }

    /// @dev withdraw function
    function withdraw() public onlyOwner {
        if (ERC20Usdt.balanceOf(address(this)) > 0) {
            uint256 amount = ERC20Usdt.balanceOf(address(this));
            uint256 fee = calculateFee(amount);
            ERC20Usdt.transfer(feeAddress, fee);
            ERC20Usdt.transfer(entrepreneur, amount - fee);
        }
        if (ERC20WBTC.balanceOf(address(this)) > 0) {
            uint256 amount = ERC20WBTC.balanceOf(address(this));
            uint256 fee = calculateFee(amount);
            ERC20WBTC.transfer(feeAddress, fee);
            ERC20WBTC.transfer(entrepreneur, amount - fee);
        }
        if (ERC20WETH.balanceOf(address(this)) > 0) {
            uint256 amount = ERC20WETH.balanceOf(address(this));
            uint256 fee = calculateFee(amount);
            ERC20WETH.transfer(feeAddress, fee);
            ERC20WETH.transfer(entrepreneur, amount - fee);
        }
        if (address(this).balance > 0) {
            uint256 amount = address(this).balance;
            uint256 fee = calculateFee(amount);
            payable(feeAddress).transfer(fee);
            payable(entrepreneur).transfer(address(this).balance);
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /// @dev calculate fee
    function calculateFee(uint256 amount) internal pure returns (uint256) {
        return (amount * FEE_PERCENTAGE) / 100;
    }

    function priceInBTC(uint256 _quantity) public view returns (uint256) {
        uint256 BTCPriceInUSD = PricesContract.getLatestPriceBTC(); /// bitcoin price in usd
        uint256 nftCostInBitcoin = (price / BTCPriceInUSD);
        return nftCostInBitcoin * _quantity;
    }

    function priceInETH(uint256 _quantity) public view returns (uint256) {
        uint256 ETHPriceInUSD = PricesContract.getLatestPriceETH(); /// bitcoin price in usd
        uint256 nftCostInETH = (price / ETHPriceInUSD);
        return nftCostInETH * _quantity;
    }

    function priceInUSDT(uint256 _quantity) public view returns (uint256) {
        return price * _quantity;
    }

    function priceInMatic(uint256 _quantity) public view returns (uint256) {
        uint256 MATICPriceInUSD = PricesContract.getLatestPriceMATIC(); /// price in usd
        uint256 nftCostInMATIC = (price / MATICPriceInUSD);
        return nftCostInMATIC * _quantity;
    }
}
