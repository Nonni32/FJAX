% WEB SCRAPING DATA FROM BONDS.IS
IndexedUrl = "http://www.bonds.is/api/market/LoadIndexed?lang=en&nonIndexed=false&nOrderbookId=-1";
NonIndexedUrl = "http://www.bonds.is/api/market/LoadIndexed?lang=en&nonIndexed=true&nOrderbookId=-1";
IndexedBonds = webread(IndexedUrl);
NonIndexedBonds = webread(NonIndexedUrl);
options = weboptions('Timeout', 30);

% CREATING A PORTFOLIO OF INDEXED BONDS
for i = 1:length(IndexedBonds)
    url = sprintf("http://www.bonds.is/api/market/LoadIndexedDetail?orderbookId=%d&lang=en", IndexedBonds(i).orderbookId);
    tempBond = bond(IndexedBonds(i), webread(url,options));
    
    if i == 1
        IndexedPortfolio = portfolio(tempBond);
    elseif tempBond.ticker([1:3])=="RIK" 
        % THE INDEXED PORTFOLIO SHOULD ONLY CONSIST OF TREASURY BONDS
        IndexedPortfolio = IndexedPortfolio.addToPortfolio(tempBond);
    end
end

% CREATING A PORTFOLIO OF NONINDEXED BONDS
for i = 1:length(NonIndexedBonds)
    url = sprintf("http://www.bonds.is/api/market/LoadIndexedDetail?orderbookId=%d&lang=en", NonIndexedBonds(i).orderbookId);
    tempBond = bond(NonIndexedBonds(i), webread(url,options));
    if i == 1
        NonIndexedPortfolio = portfolio(tempBond);
    else
        NonIndexedPortfolio = NonIndexedPortfolio.addToPortfolio(tempBond);
    end
end

