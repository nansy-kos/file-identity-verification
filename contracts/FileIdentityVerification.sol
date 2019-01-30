pragma solidity >=0.4.21<0.6.0;

// ---------------------------------------------
// FileIdentityVerification.sol
// ---------------------------------------------
// Copyright (c) 2019 PLUSPLUS CO.,LTD.
// Released under the MIT license
// https://www.plusplus.jp/
// ---------------------------------------------

//
// File identity verification
//
contract FileIdentityVerification {

    struct FileIdentity {
        bytes32 keccak256hash;
        string sha3hash;
        address registrant;
        uint timestamp;
        uint isExist;
    }

    // Owner of Smart Contract
    // スマートコントラクトのオーナー
    address public owner;

    // Cumulative number of hashes registered
    // ハッシュを登録した累計回数
    uint public number_of_hashes_registered;

    // Number of valid hashes
    // 有効なハッシュの数
    uint public number_of_valid_hashes;

    // Keep a list of hashes
    // ハッシュの一覧を保持する
    mapping(bytes32 => FileIdentity) private fileIdentityList;

    modifier onlyOwner() {
        require(msg.sender == owner, 'Only the owner is available.');
        _;
    }

    string private NO_DATA = 'Data does not exist';
    string private ALREADY_REGISTERED = 'It is already registered';
    string private NO_DELETE_AUTHORITY = 'You do not have permission to delete';

    // Events
    event RegisterFileHash(address indexed _from, bytes32 _keccak256hash, string _sha3hash, uint _timestamp);
    event RemoveFileHash(address indexed _from, bytes32 _keccak256hash, string _sha3hash, uint _timestamp);

    constructor() public {
        // The owner address is maintained.
        owner = msg.sender;

        number_of_hashes_registered = 0;
        number_of_valid_hashes = 0;
    }

    // ファイル情報を照会
    function getFileIdentity(bytes32 _keccak256hash) public view
    returns (bytes32 keccak256hash, string sha3hash, address registrant, uint timestamp, uint isExist){
        FileIdentity memory d = fileIdentityList[_keccak256hash];
        return (d.keccak256hash, d.sha3hash, d.registrant, d.timestamp, d.isExist);
    }

    // Obtain a hash value
    // ハッシュ値を得る
    function getKeccak256Hash(string _sha3hash) public pure returns (bytes32) {
        bytes32 keccak256hash = keccak256(abi.encodePacked(_sha3hash));
        return keccak256hash;
    }

    // File existence check
    // ファイルの存在チェック
    function isExist(bytes32 _keccak256hash) public view returns (bool) {
        if (fileIdentityList[_keccak256hash].isExist == 1) {
            // exist
            return true;
        }
        else {
            // not exist
            return false;
        }
    }

    // Whether you are the owner of the file
    // あなたがファイルの登録者であるか
    function isYourRegistration(bytes32 _keccak256hash) public view returns (bool) {

        require(isExist(_keccak256hash) == true, NO_DATA);

        if (msg.sender == fileIdentityList[_keccak256hash].registrant) {
            return true;
        }
        else {
            return false;
        }
    }

    // Register file hash
    // ファイルハッシュを登録する
    function registerFileHash(string _sha3hash) public returns (bool) {

        bytes32 _keccak256hash = getKeccak256Hash(_sha3hash);

        require(isExist(_keccak256hash) == false, ALREADY_REGISTERED);

        uint ts = block.timestamp;

        fileIdentityList[_keccak256hash].isExist = 1;
        fileIdentityList[_keccak256hash].keccak256hash = _keccak256hash;
        fileIdentityList[_keccak256hash].sha3hash = _sha3hash;
        fileIdentityList[_keccak256hash].registrant = msg.sender;
        fileIdentityList[_keccak256hash].timestamp = ts;

        emit RegisterFileHash(msg.sender, _keccak256hash, _sha3hash, ts);

        // Add actual registration number
        // 実際の登録数
        ++number_of_valid_hashes;

        // Add cumulative number
        // 累計数
        ++number_of_hashes_registered;

        return true;
    }

    // remove file hash
    // ファイルハッシュを抹消する
    function removeFileHash(bytes32 _keccak256hash) public returns (bool) {

        require(isExist(_keccak256hash) == true, NO_DATA);
        require(isYourRegistration(_keccak256hash) == true, NO_DELETE_AUTHORITY);

        uint ts = block.timestamp;

        bytes32 o_keccak256hash = fileIdentityList[_keccak256hash].keccak256hash;
        string memory o_sha3hash = fileIdentityList[_keccak256hash].sha3hash;

        delete fileIdentityList[_keccak256hash];
        emit RemoveFileHash(msg.sender, o_keccak256hash, o_sha3hash, ts);

        // Reduce the actual number of registrations
        // 実際の登録数を減らす
        --number_of_valid_hashes;

        return true;
    }

    // ---------------------------------------------
    // Destruction of a contract (only owner)
    // ---------------------------------------------
    function destory(string _delete_me) public onlyOwner {
        // Delete by giving keyword
        require(getKeccak256Hash('delete me') == getKeccak256Hash(_delete_me), 'The keywords do not match.');
        selfdestruct(owner);
    }

}
