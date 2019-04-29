IndexedUrl = "http://www.bonds.is/api/market/LoadIndexed?lang=en&nonIndexed=true&nOrderbookId=-1";
nonIndexedUrl = "http://www.bonds.is/api/market/LoadIndexed?lang=en&nonIndexed=false&nOrderbookId=-1";
ind = webread(nonIndexedUrl);
non = webread(IndexedUrl);

interest = [0.038 0.0375 0.015 0.0325 0.0375 0.0375; 0.0625 0.0725 0.08 0.05 0.0625 -inf]
coupon = [1 2 1 1 2 2; 1 1 1 1 1 -inf]
