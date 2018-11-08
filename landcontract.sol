pragma solidity ^0.4.11;

contract LandContract {
    address owner;
    mapping (address => uint) public balances;
    
    struct Plot {
        address owner;
        bool forSale;
        uint price;
    }
    
    Plot[5] public plots;
    
    event PlotOwnerChanged(
        uint index
    );
    
    event PlotPriceChanged(
        uint index,
        uint price
    );
    
    event PlotAvailabilityChanged(
        uint index,
        uint price,
        bool forSale
    );
    
    constructor() public {
        owner = msg.sender;
        plots[0].price = 4000;
        plots[0].forSale = true;
        plots[1].price = 4000;
        plots[1].forSale = true;
        plots[2].price = 4000;
        plots[2].forSale = true;
        plots[3].price = 4000;
        plots[3].forSale = true;
        plots[4].price = 4000;
        plots[4].forSale = true;
        
    }
    
    function putPlotUpForSale(uint index, uint price) public {
        Plot storage plot = plots[index];
        
        require(msg.sender == plot.owner && price > 0);
        
        plot.forSale = true;
        plot.price = price;
        emit PlotAvailabilityChanged(index, price, true);
    }
    
    function takeOffMarket(uint index) public {
        Plot storage plot = plots[index];
        
        require(msg.sender == plot.owner);
        
        plot.forSale = false;
        emit PlotAvailabilityChanged(index, plot.price, false);
    }
    
    function getPlots() public view returns(address[], bool[], uint[]) {
        address[] memory addrs = new address[](5);
        bool[] memory available = new bool[](5);
        uint[] memory price = new uint[](5);
        
        for (uint i = 0; i < 5; i++) {
            Plot storage plot = plots[i];
            addrs[i] = plot.owner;
            price[i] = plot.price;
            available[i] = plot.forSale;
        }
        
        return (addrs, available, price);
    }
    
    function buyPlot(uint index) public payable {
        Plot storage plot = plots[index];
        
        require(msg.sender != plot.owner && plot.forSale && msg.value >= plot.price);
        
        if(plot.owner == 0x0) {
            balances[owner] += msg.value;
        }else {
            balances[plot.owner] += msg.value;
        }
        
        plot.owner = msg.sender;
        plot.forSale = false;
        
        emit PlotOwnerChanged(index);
    }
    
    function withdrawFunds() public {
        address payee = msg.sender;
          uint payment = balances[payee];
    
          require(payment > 0);
    
          balances[payee] = 0;
          require(payee.send(payment));
    }
    
    
    function destroy() payable public {
        require(msg.sender == owner);
        selfdestruct(owner);
    }
}