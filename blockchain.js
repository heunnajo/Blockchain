const SHA256 = require('crypto-js/sha256') //getting from installed module

class Block {
    constructor(index, timestamp, data, previousHash = ' ') {//make such blueprint
    this.index = index;
    this.timestamp = timestamp;
    this.data = data;
    this.previousHash = previousHash;
    this.hash = this.calculateHash();
    this.nonce = 0;//random
    }

    calculateHash() {
        //hash function of block header
        return SHA256(this.index + this.previousHash + this.timestamp + JSON.stringify(this.data) + this.nonce).toString();

    }

    //Mining block
    mineBlock(difficulty){//compare and if it is not matched, set index 0 again.
        while(this.hash.substring(0,difficulty) !== Array(difficulty + 1).join("0")){
            this.nonce++;
            this.hash = this.calculateHash();//calculate function 다시
        }
        //Broadcast that a block is created
        console.log("Block minded " + this.hash);
    }
}

class BlockChain {
    constructor () {
        //Create the first block and set a condition
        this.chain = [this.createGenesisBlock()];//It's gonna be a array
        this.difficulty = 5;
    }
    createGenesisBlock() {
        //Starts from 01/01/2017, Genesis block is created and the index is 0.
        return new Block(0,"01/01/2017","Genesis block",0);
    }

    getLatestBlock(){//find out the latest block
        return this.chain[this.chain.length-1];
    }

    addBlock(newBlock) {
        newBlock.previousHash = this.getLatestBlock().hash;
        newBlock.mineBlock(this.difficulty);
        //Adding a new block
        this.chain.push(newBlock);
    }
    //chain validation check
    isChainValid() {
        for(let i = 1; i < this.chain.length; i++) {
            const currentBlock = this.chain[i];
            const previousBlock = this.chain[i-1];

            if(currentBlock.hash !== currentBlock.calculateHash()) {
                return false;//Not Valid.
            }
            if(currentBlock.previousHash !== previousBlock.hash){
                return false;//Not Valid.
            }
        }
        return true;
    }
}

//Create genesis block
let heunCoin = new BlockChain();

console.log('Mining block 1...');            // array
heunCoin.addBlock(new Block(1,"10/08/2017", {amount : 4}));

console.log('Mining block 2...');            // array
heunCoin.addBlock(new Block(2,"12/08/2017", {amount : 10}));
//Stringify the object, can skip it.
console.log(JSON.stringify(heunCoin, null, 4));

console.log('Is blockchain valid?' + heunCoin.isChainValid());
