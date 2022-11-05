pragma soildity 0.5.2;
pragma experimental ABIEncoderV2;

library SafeMath{
    function safeAdd(uint a,uint b) public pure returns (uint c){
        c=a+b;
        require(c >= a);// do google search (require)
    }
    function safeSub(uint a,uint b) public pure returns (uint c){
        require(b<= a);
        c= a-b;
    }
    function safeMul(uint a,uint b) public pure returns (uint c){
        c= a*b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a,uint b) public pure returns (uint c){
        require(b > 0);
        c = a/b;
    }

    }
    contract Auction_Manager {
        using SafeMath for uint;
        enum Auction_State{
            Created,
            Live,
            Closed

        }
        enum Bid_State{
            Placed,
            Accepted
        }
        struct Auction{
            string Auction_ID;
            address Auction_Owner;
            uint256 Highest_Bid;
            uint256 Auction_Start_Date;
            uint256 Auction_Expiry_Date;
            bool Auction_is_live;
            address Top_Bidder;
            uint Auction_Index;
            Auction_Manager.Auction_State state;
        }
        struct Bid{
            string Bid_ID;
            string Auction_ID;
            string Payable_date;
            address Bid_Owner;
            uint256 Bid_value;
            bool bid_accepted;
        }
        mapping (uint => Auction) public auctions;
        mapping (uint => Bid[]) public bids;
        mapping(address => uint) balances;

        modifier onlyAuctionOwner(uint _auction_index){
            require(msg.sender == auctions[_auction_index].Auction_Owner,"Only Auction owner allowed");
            _;
        }
        modifier onlyBidOwner(uint _bid_index,uint _auction_index){
            require(msg.sender == bids[_auction_index][_bid_index].Bid_Owner,"Only bid owner allowed");
            _;
        }
        modifier onlyauction_Or_BidOwner(uint _bid_index, uint _auction_index){
            require((msg.sender == auctions[_auction_index].Auction_Owner) || (msg.sender == bids[_auction_index][_bid_index].Bid_Owner),"You should be auction or bid owner");
            _;
        }
        Auction[] auction_list;
        
        uint auction_index=0;
        uint bid_index=0;

        function Create_Auction(string memory _Auction_ID ) public returns (bool success){
            auctions[auction_index].Auction_ID = _Auction_ID;
            auctions[auction_index].Highest_Bid=0;
            auctions[auction_index].Auction_Owner=msg.sender;
            auctions[auction_index].state=Auction_State.Created;
            auctions[auction_index].Auction_Start_Date = now;
            auctions[auction_index].Auction_Expiry_Date = now + 90 seconds;
            auctions[auction_index].Auction_is_live = true;
            auctions[auction_index].Auction_Index= auction_index;
            auction_index++;
            return success = true;
        }
        function Read_Auction (uint _auction_index) public view returns(string memory Auction_ID,address Auction_Owner, uint256 Highest_Bid, Auction_Manager.Auction_State,uint256 Auction_Start_Date,uint256 Auction_Expiry_Date,bool Auction_is_live,uint256 Auction_Index ){
        Auction storage a = auctions[_auction_index];
        return (a.Auction_ID, a.Auction_Owner, a.Highest_Bid,a.state,a.Auction_Start_Date,a.Auction_Expiry_Date,a.Auction_is_live, a.Auction_Index);
        }
        function Place_Bid(uint _auction_index,string memory _Bid_ID, uint256 _Bid_Amount, string memory payble_date) public returns(bool success){
            require (auctions[_auction_index].Auction_Owner != msg.sender,"Auction Owner should not bid on Own Auction");
            require (auctions[_auction_index].Auction_is_live,"Auction Should be live to place Bid");
            uint i;
            bool exists=false;

            for (i=0;i<bids[_auction_index].length;i++){
                if(bids[_auction_index][i].Bid_Owner==msg.sender){
                    require(bids[_auction_index][i].Bid_value < _Bid_Amount,"Bid must be larger than previous");
                    exists = true;
                    break;
                }
            }
        }
        if (exists == true) {
            bids[_auction_index][i].Bid_value = _Bid_Amount;
        }//  re-bidding
        else{
            bids[_auction_index].push(Bid({
                Bid_ID : _Bid_ID,
                Auction_ID : auctions[_auction_index].Auction_ID,
                Bid_Owner : msg.sender,
                Bid_value : _Bid_Amount,
                Payable_date : payble_date,
                bid_accepted : false
            }));
        }// first time bidding

        bid_index++;
        if(auction[_auction_index].Highest_Bid < _Bid_Amount){
           auction[_auction_index].Highest_Bid = _Bid_Amount;
           auction[_auction_index].state = Auction_State.Live; 
        }
        return success = true;
        function Total_bid (uint _auction_index) public view onlyAuctionOwner(_auction_index) returns (uint){
            return bids[_auction_index].length;
        }
        function Read_Bid (uint -bid_index,uint _auction_index) public view onlyauction_Or_BidOwner (_bid_index,_auction_index) returns (Bid){
            bid storage b= bids[_auction_index][_bid_index];
            return b;
        }
        function readAllBids(uint _auction_index) public view onlyAuctionOwner(_auction_index) returns(Bid[] memory){
            return bids[_auction_index];
        }
        function Accept_Bid(uint _bid_index,uint _auction_index) public onlyAuctionOwner(_auction_index){
            bids[_auction_index][_bid_index].bid_accepted=true;
            auctions[_auction_index].state= Auction_State.Closed;
            auctons[_auction_index].Auction_is_live=false;
        }
        function Close_Auction (uint _auction_index) public onlyAuctionOwner(_auction_index) returns (bool success){
            require(now > auctions[auction_index].Auction_state_Date);
            auctions[_auction_index].State=Auction_State.Closed;
            auctions[_auction_index].Auction_is_live=false;
            return success = true;
        }
        function Repay_Auction(uint _bid_index,uint _auction_index) payable public onlyAuctionOwner(_bid_index, _auction_index) returns (bool){
            require(msg.value == bids[_auction_index][_bid_index].Bid_value);
            require(bids[_auction_index][_bid_index].bid_accepted=true);
            address Auction_Owner = auctions[_auction_index].Auction_Owner;
            return success =true;
        }
    }

