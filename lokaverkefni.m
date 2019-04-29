% WEB SCRAPING DATA FROM BONDS.IS
IndexedUrl = "http://www.bonds.is/api/market/LoadIndexed?lang=en&nonIndexed=true&nOrderbookId=-1";
NonIndexedUrl = "http://www.bonds.is/api/market/LoadIndexed?lang=en&nonIndexed=false&nOrderbookId=-1";
IndexedBonds = webread(NonIndexedUrl);
NonIndexedBonds = webread(IndexedUrl);

NonIndexedPortfolio = [];

for i = 1:length(IndexedBonds)
    url = sprintf("http://www.bonds.is/api/market/LoadIndexedDetail?orderbookId=%d&lang=en",IndexedBonds(i).orderbookId);
    tempBond = bond(IndexedBonds(i), webread(url));
    if i == 1
        IndexedPortfolio = portfolio(tempBond);
    else
        IndexedPortfolio.addToPortfolio(tempBond);
    end
end

IndexedPortfolio