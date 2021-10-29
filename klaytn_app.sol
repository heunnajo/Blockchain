// Klaytn IDE uses solidity 0.4.24, 0.5.6 versions.
pragma solidity >=0.4.24 <=0.5.6;

interface ERC721 /* is ERC165 */ {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    function balanceOf(address _owner) public view returns (uint256);
    function ownerOf(uint256 _tokenId) public view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public;
    function safeTransferFrom(address _fr
    om, address _to, uint256 _tokenId) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function approve(address _approved, uint256 _tokenId) public;
    function setApprovalForAll(address _operator, bool _approved) public;
    function getApproved(uint256 _tokenId) public view returns (address);
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);
}
interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}
interface ERC165 {
    function supportsInterface(bytes4 interfaceID) public view returns (bool);
}
contract ERC721Implementation is ERC721{
    //매핑 2개 구현
    mapping(uint256 => address) tokenOwner;//토큰의 아이디로 토큰의 주인이 누구인지 확인:토큰의 아이디(unit256)을 key값으로 해서 계정(address)을 리턴
    mapping(address => uint256) ownedTokensCount;//address 타입을 key로 쓰고 uint256을 value로 리턴 : 계정 주소 입력하면 해당 계정이 토큰을 몇개 소유하고 있는지 숫자로 리턴
    mapping(uint256 => address) tokenApprovals;
    mapping(address => mapping (address => bool)) operatorApprovals;
    mapping(bytes4 => bool) supportedInterfaces;
    
    constructor() public{
        supportedInterfaces[0x80ac58cd] = true;
    }
    
    function mint(address _to, uint _tokenId) public {//mint:발행하다,_to:누가 소유할 것인지, _tokenId:몇번째 토큰인지
        tokenOwner[_tokenId] = _to;//소유주를 _to로 설정
        ownedTokensCount[_to] += 1;//토큰 발행할 때마다 특정 계정이 총 몇개의 토큰을 소유하고 있는지 카운팅
    }
    
    function balanceOf(address _owner) public view returns (uint256) {
        return ownedTokensCount[_owner];//_owner가 소유한 토큰 갯수를 리턴
    }
    function ownerOf(uint256 _tokenId) public view returns (address) {
        return tokenOwner[_tokenId];//토큰의 주인이 누구인지를 리턴:tokenId를 키값으로 해서 tokenId 소유자 계정을 리턴.
    }
    function transferFrom(address _from, address _to, uint256 _tokenId) public{
        address owner = ownerOf(_tokenId);
        require(msg.sender == owner || getApproved(_tokenId) == msg.sender || isApprovedForAll(owner,msg.sender));
        require(_from != address(0));
        require(_to != address(0));
        
        ownedTokensCount[_from] -= 1;
        tokenOwner[_tokenId] = address(0);//토큰 소유권 삭제
        
        ownedTokensCount[_to] += 1;
        tokenOwner[_tokenId] = _to;//_to 가 해당 토큰의 새로운 소유자이다!
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public{
        transferFrom(_from, _to, _tokenId);
        
        if(isContract(_to)){
            bytes4 returnValue = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, '');
            require(returnValue == 0x150b7a02);//만족해야 통과된다!
        }
    }
    function approve(address _approved, uint256 _tokenId) public{
        address owner = ownerOf(_tokenId);
        require(_approved != owner);
        require(msg.sender == owner);
        tokenApprovals[_tokenId] = _approved;
    }
    function getApproved(uint256 _tokenId) public view returns (address){
        return tokenApprovals[_tokenId];
    }
    function setApprovalForAll(address _operator, bool _approved) public{
        require(_operator != msg.sender);
        operatorApprovals[msg.sender][_operator] = _approved;
    }
    function isApprovedForAll(address _owner, address _operator) public view returns (bool){
        return operatorApprovals[msg.sender][_operator];
    }
    function supportsInterface(bytes4 interfaceID) public view returns (bool){
        return supportedInterfaces[interfaceID];
    }
     //_to가 컨트랙계정인지 확인하는 함수
    function isContract(address _addr) private view returns (bool){
        uint256 size;
        assembly { size:= extcodesize(_addr) }
        return size > 0;//크기가 0보다 크다면 컨트랙 계정이고, true를 리턴, 0이면 일반 계정
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public{
        transferFrom(_from, _to, _tokenId);
        
        if(isContract(_to)){
            bytes4 returnValue = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);
            require(returnValue == 0x150b7a02);//만족해야 통과된다!
        }
    }
}
//외부컨트랙을 만들어서 ERC721TokenReceiver를 상속받도록 한다.따라서 함수 구현한다.
contract Auction is ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) public returns(bytes4){
        //magic value를 리턴해야하는데 단순히 함수 시그니처를 리턴하면 된다. 이 리턴값이 바로 위의 magic value=0x150b7a02 이다!
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
    function checkSupportsInterface(address _to, bytes4 interfaceID) public view returns (bool){
        return ERC721Implementation(_to).supportsInterface(interfaceID);
    }
}





















