// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Auction {

    uint INTERVAL = 60000;    // 与上一个拍卖品的最低间隔一分钟
    uint LEASTMARKUP = 100;     // 最低加价

    struct Lot {
        uint id;
        address auctioneer;
        uint endTimestamp;

        address payable seller;
        string name;
        string token;           // 暂时不加入NFT，此变量无效
        string info;

        address payable bidder;
        uint highestPrice;

        bool finished;
    }

    address auctioneer;
    Lot[] lots;
    uint posted_count;
    uint current_idx;
    mapping(uint => uint) indexMapping;         // id mapping to index
    mapping(uint => bool) isExistMapping;       // 
    mapping(uint => bool) isFinishedMapping;    // if finished

    constructor() {
        auctioneer = msg.sender;
        posted_count = 0;
        current_idx = 0;
    }

    function post(uint _id, string memory _name, string memory _info, uint _endTimestamp) public payable {
        require(!isExistMapping[_id]);
        if (posted_count > 0) {
            require(_endTimestamp > (lots[posted_count - 1].endTimestamp + INTERVAL));
        }
        string memory _token = '';
        lots.push(Lot(_id, auctioneer, _endTimestamp, payable(msg.sender), _name, _token, _info, payable(address(0x0)), 0, false));
        posted_count += 1;
    }

    function bid(uint _price) public payable {
        require(!lots[current_idx].finished);
        require(_price >= (lots[current_idx].highestPrice + LEASTMARKUP));
        // 将上一个竞标的钱退还给上一个竞标者
        lots[current_idx].bidder.transfer((lots[current_idx].highestPrice * 1000000000000));
        // 更改新的竞标人和竞标价
        lots[current_idx].bidder = payable(msg.sender);
        lots[current_idx].highestPrice = _price;
    }

    function pass() public payable {
        require(msg.sender == auctioneer);
        require(!lots[current_idx].finished);
        lots[current_idx].finished = true;
        // 此处可以加入拍卖行的手续费给auctioneer
        lots[current_idx].seller.transfer((lots[current_idx].highestPrice * 1000000000000));
        current_idx += 1;
    }

    function get_current_lot() public view returns(Lot memory) {
        require(current_idx < posted_count);
        return lots[current_idx];
    }

    function get_candidate_lots() public view returns(Lot[] memory) {
        require(current_idx < posted_count - 1);
        Lot[] memory candidates = new Lot[](posted_count - current_idx - 2);
        uint idx = 0;
        for (uint i = current_idx + 1; i < posted_count; i++) {
            candidates[idx] = lots[i];
            idx += 1;
        }
        return candidates;
    }

    function get_latest_lot() public view returns(Lot memory) {
        require(posted_count > 0);
        return lots[posted_count - 1];
    }
}
