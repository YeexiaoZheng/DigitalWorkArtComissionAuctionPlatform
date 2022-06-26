// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract ArtComission {
    struct Comission {
        uint id;
        address payable authorAddress;
        string author;
        string title;
        uint price;
        string info;
        bool finished;
        address purchaserAddress;
    }

    Comission[] comissions;
    uint posted_count;
    uint finished_count;
    mapping(uint => uint) indexMapping;         // id mapping to index
    mapping(uint => bool) isExistMapping;       // 
    mapping(uint => bool) isFinishedMapping;    // if finished
    
    // constructor() public {
        
    // }

    function post(uint _id, string memory _author, string memory _title, uint _price, string memory _info) public payable returns (uint) {
        // address payable _authorAddress = address(uint160(msg.sender));
        address payable _authorAddress = payable(msg.sender);
        
        if (isExistMapping[_id]) {
            Comission memory comission = comissions[indexMapping[_id]];
            require(comission.authorAddress == _authorAddress);
            require(!isFinishedMapping[_id]);
            comission.author = _author;
            comission.title = _title;
            comission.price = _price;
            comission.info = _info;
            comissions[indexMapping[_id]] = comission;
        } else {
            comissions.push(Comission(
                _id, _authorAddress, _author, _title, _price , _info, 
                false, address(0x0)
            ));
            indexMapping[_id] = posted_count;
            isExistMapping[_id] = true;
            isFinishedMapping[_id] = false;
            posted_count += 1;
        }
        
        return _id;
    }

    function purchase(uint _id) public payable {
        require(isExistMapping[_id]);
        require(!isFinishedMapping[_id]);
        address _purchaserAddress = msg.sender;
        Comission memory comission = comissions[indexMapping[_id]];
        comission.authorAddress.transfer((comission.price * 1000000000000));
        comission.finished = true;
        comission.purchaserAddress = _purchaserAddress;
        comissions[indexMapping[_id]] = comission;
        isFinishedMapping[_id] = true;
        finished_count += 1;
    }

    function get_all_comissions() public view returns(Comission[] memory) {
        return comissions;
    }

    function get_selected_comissions(bool _finished) public view returns(Comission[] memory) {
        uint idx = 0;
        if (_finished) {
            Comission[] memory selected_comissions = new Comission[](finished_count);
            for (uint i = 0; i < posted_count; i++) { 
                if (comissions[i].finished == true) {
                    selected_comissions[idx] = comissions[i];
                    idx += 1;
                }
            }
            return selected_comissions;
        } else {
            Comission[] memory selected_comissions = new Comission[](posted_count - finished_count);
            for (uint i = 0; i < posted_count; i++) { 
                if (comissions[i].finished == false) {
                    selected_comissions[idx] = comissions[i];
                    idx += 1;
                }
            }
            return selected_comissions;
        } 
    }

}