DROP SCHEMA IF EXISTS bigbull CASCADE;
CREATE SCHEMA bigbull;
SET search_path TO bigbull;
-- 1. BASE TABLES
CREATE TABLE AppUser (
 UserId VARCHAR(50) PRIMARY KEY,
 Name VARCHAR(100) NOT NULL,
 Email VARCHAR(100) UNIQUE NOT NULL,
 PhoneNumber VARCHAR(20) UNIQUE,
 Address VARCHAR(255),
 PanNumber VARCHAR(20) UNIQUE,
 KycStatus VARCHAR(20) CHECK (KycStatus IN ('Verified', 'Pending',
'Unverified'))
);
CREATE TABLE Company (
 CompanyName VARCHAR(100) PRIMARY KEY,
 Sector VARCHAR(50) NOT NULL
);
-- 2. ACCOUNTS
CREATE TABLE DematAccount (
 DematAccId VARCHAR(50) PRIMARY KEY,
 LinkedDepository VARCHAR(50),
 DateOpened DATE DEFAULT CURRENT_DATE,
 UserId VARCHAR(50) UNIQUE NOT NULL,
 FOREIGN KEY (UserId) REFERENCES AppUser(UserId) ON DELETE CASCADE
);
CREATE TABLE TradingAccount (
 TradingAccId VARCHAR(50) PRIMARY KEY,
 AvlBalance DECIMAL(15,2) DEFAULT 0.00,
 UserId VARCHAR(50) UNIQUE NOT NULL,
 FOREIGN KEY (UserId) REFERENCES AppUser(UserId) ON DELETE CASCADE
);
CREATE TABLE LinkedBankAccount (
 BankAccountNo VARCHAR(30) PRIMARY KEY,
 IFSC_Code VARCHAR(15) NOT NULL,
 BankName VARCHAR(100),
 IsPrimary BOOLEAN DEFAULT FALSE,
 UserId VARCHAR(50) NOT NULL,
 FOREIGN KEY (UserId) REFERENCES AppUser(UserId) ON DELETE CASCADE
);
-- 3. MARKET
CREATE TABLE Financial_Instruments (
 Ticker_Symbol VARCHAR(20) PRIMARY KEY,
 Instrument_Type VARCHAR(50),
 Exchange VARCHAR(20),
 CompanyName VARCHAR(100) NOT NULL,
 FOREIGN KEY (CompanyName) REFERENCES Company(CompanyName)
);
CREATE TABLE MarketData (
 Ticker_Symbol VARCHAR(20) NOT NULL,
 TimeStamp TIMESTAMP NOT NULL,
 DailyHigh DECIMAL(10,2),
 DailyLow DECIMAL(10,2),
 CurrPrice DECIMAL(10,2),
 Volume BIGINT,
 PRIMARY KEY (Ticker_Symbol, TimeStamp),
 FOREIGN KEY (Ticker_Symbol) REFERENCES Financial_Instruments(Ticker_Symbol)
);
-- 4. PORTFOLIO
CREATE TABLE Portfolio_Holds (
 DematAccId VARCHAR(50) NOT NULL,
 Ticker_Symbol VARCHAR(20) NOT NULL,
 Current_Quantity_Held INT DEFAULT 0,
 PRIMARY KEY (DematAccId, Ticker_Symbol),
 FOREIGN KEY (DematAccId) REFERENCES DematAccount(DematAccId),
 FOREIGN KEY (Ticker_Symbol) REFERENCES Financial_Instruments(Ticker_Symbol)
);
-- 5. TRADING
CREATE TABLE Orders (
 Order_ID VARCHAR(50) PRIMARY KEY,
 Order_Type VARCHAR(20) CHECK (Order_Type IN ('BUY', 'SELL')),
 Price DECIMAL(10,2),
 Status VARCHAR(20) CHECK (Status IN ('Pending', 'Executed', 'Cancelled')),
 OrderQty INT NOT NULL,
 TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 TradingAccId VARCHAR(50) NOT NULL,
 Ticker_Symbol VARCHAR(20) NOT NULL,
 FOREIGN KEY (TradingAccId) REFERENCES TradingAccount(TradingAccId),
 FOREIGN KEY (Ticker_Symbol) REFERENCES Financial_Instruments(Ticker_Symbol)
);
CREATE TABLE Trade (
 Trade_ID VARCHAR(50) PRIMARY KEY,
 Execution_Qty INT NOT NULL,
 Execution_Price DECIMAL(10,2) NOT NULL,
 Execution_Time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 Order_ID VARCHAR(50) NOT NULL,
 DematAccId VARCHAR(50) NOT NULL,
 FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
 FOREIGN KEY (DematAccId) REFERENCES DematAccount(DematAccId)
);
-- 6. WATCHLIST
CREATE TABLE Watchlist (
 Watchlist_ID VARCHAR(50) PRIMARY KEY,
 Watchlist_Name VARCHAR(100) NOT NULL,
 UserId VARCHAR(50) NOT NULL,
 FOREIGN KEY (UserId) REFERENCES AppUser(UserId)
);
CREATE TABLE Watchlist_Contains (
 Watchlist_ID VARCHAR(50) NOT NULL,
 Ticker_Symbol VARCHAR(20) NOT NULL,
 PRIMARY KEY (Watchlist_ID, Ticker_Symbol),
 FOREIGN KEY (Watchlist_ID) REFERENCES Watchlist(Watchlist_ID),
 FOREIGN KEY (Ticker_Symbol) REFERENCES Financial_Instruments(Ticker_Symbol)
);
-- 7. TRANSACTIONS
CREATE TABLE Financial_Transaction (
 Transaction_ID VARCHAR(50) PRIMARY KEY,
 Transaction_Type VARCHAR(50) NOT NULL,
 Amount DECIMAL(15,2) NOT NULL,
 Payment_Method VARCHAR(50),
 Status VARCHAR(20),
 TimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 TradingAccId VARCHAR(50) NOT NULL,
 BankAccountNo VARCHAR(30),
 FOREIGN KEY (TradingAccId) REFERENCES TradingAccount(TradingAccId),
 FOREIGN KEY (BankAccountN