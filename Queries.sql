-- 1. User Net Worth (Current holdings valuation + cash)
--Calculates U1 total value by adding his cash balance to the current market value of all his stocks.
SELECT u.Name, (ta.AvlBalance + COALESCE(SUM(ph.Current_Quantity_Held *
md.DailyHigh), 0)) as Total_Net_Worth FROM AppUser u
JOIN TradingAccount ta ON u.UserId = ta.UserId
LEFT JOIN DematAccount da ON u.UserId = da.UserId
LEFT JOIN Portfolio_Holds ph ON da.DematAccId = ph.DematAccId
LEFT JOIN (SELECT DISTINCT ON (Ticker_Symbol) Ticker_Symbol, DailyHigh FROM
MarketData ORDER BY Ticker_Symbol, TimeStamp DESC) md ON ph.Ticker_Symbol =
md.Ticker_Symbol
WHERE u.UserId = 'U1' GROUP BY u.Name, ta.AvlBalance;
-- 2. Portfolio Breakdown
--Lists the specific companies and quantities of stocks held in the "D1" demat account.
SELECT fi.Ticker_Symbol, c.CompanyName, ph.Current_Quantity_Held
FROM Portfolio_Holds ph
JOIN Financial_Instruments fi ON ph.Ticker_Symbol = fi.Ticker_Symbol
JOIN Company c ON fi.CompanyName = c.CompanyName
WHERE ph.DematAccId = 'D1';
-- 3. Sector Concentration
-- Counts how many different stocks account "D1" holds within each industry (e.g., Technology,
-- Energy).
SELECT c.Sector, COUNT(fi.Ticker_Symbol) as Stock_Count
FROM Portfolio_Holds ph
JOIN Financial_Instruments fi ON ph.Ticker_Symbol = fi.Ticker_Symbol
JOIN Company c ON fi.CompanyName = c.CompanyName
WHERE ph.DematAccId = 'D1' GROUP BY c.Sector;
-- 4. Inactive Investors
--Identifies users who have a demat account but havent actually bought any stocks yet.
SELECT u.Name FROM AppUser u
JOIN DematAccount da ON u.UserId = da.UserId
LEFT JOIN Portfolio_Holds ph ON da.DematAccId = ph.DematAccId
WHERE ph.Ticker_Symbol IS NULL;
-- 5. High-Value Portfolios (>50 shares total)
-- Finds all demat accounts that hold a total of more than 50 shares across all their combined
-- stocks.
SELECT DematAccId, SUM(Current_Quantity_Held) FROM Portfolio_Holds
GROUP BY DematAccId HAVING SUM(Current_Quantity_Held) > 50;
-- 6. Diversification Check (>3 sectors)
-- Identifies "power users" who have diversified their investments across more than 3 different
-- industry sectors.
SELECT da.UserId FROM Portfolio_Holds ph
JOIN Financial_Instruments fi ON ph.Ticker_Symbol = fi.Ticker_Symbol
JOIN Company c ON fi.CompanyName = c.CompanyName
JOIN DematAccount da ON ph.DematAccId = da.DematAccId
GROUP BY da.UserId HAVING COUNT(DISTINCT c.Sector) > 3;
-- 7. Capital Distribution per Sector (Platform-wide)
--Provides a platform-wide view of how many total shares are held by all users in each sector.
SELECT c.Sector, SUM(ph.Current_Quantity_Held) as Total_Quantity
FROM Portfolio_Holds ph
JOIN Financial_Instruments fi ON ph.Ticker_Symbol = fi.Ticker_Symbol
JOIN Company c ON fi.CompanyName = c.CompanyName
GROUP BY c.Sector;
-- 8. User Contact Directory (Verified)
--Generates a mailing list of "Verified" users along with their current available trading cash.
SELECT u.Name, u.Email, ta.AvlBalance FROM AppUser u
JOIN TradingAccount ta ON u.UserId = ta.UserId
WHERE u.KycStatus = 'Verified';
-- 9. Sector Exposure (Technology % for U1)
-- Calculates what percentage of U1 total share count is concentrated specifically in the
-- "Technology" sector.
SELECT (SUM(CASE WHEN c.Sector = 'Technology' THEN ph.Current_Quantity_Held ELSE
0 END) * 100.0 / SUM(ph.Current_Quantity_Held)) as Tech_Exposure_Pct
FROM Portfolio_Holds ph
JOIN Financial_Instruments fi ON ph.Ticker_Symbol = fi.Ticker_Symbol
JOIN Company c ON fi.CompanyName = c.CompanyName
WHERE ph.DematAccId = 'D1';
-- 10. Holding Valuation (Live-ish)
-- Shows the current dollar/rupee value of every stock holding in the system based on the latest
-- market highs.
SELECT ph.Ticker_Symbol, (ph.Current_Quantity_Held * md.DailyHigh) as Valuation
FROM Portfolio_Holds ph
JOIN (SELECT DISTINCT ON (Ticker_Symbol) Ticker_Symbol, DailyHigh
FROM MarketData ORDER BY Ticker_Symbol, TimeStamp DESC) md
ON ph.Ticker_Symbol = md.Ticker_Symbol;
-- 11. Depository Split
-- Shows the market share between different depositories (NSDL vs. CDSL) by counting linked
-- accounts.
SELECT LinkedDepository, COUNT(*) FROM DematAccount
GROUP BY LinkedDepository;
-- 12. High Balance / Unverified KYC
-- Flags users who have deposited money but havent finished their legal verification—a potential
-- compliance risk.
SELECT u.Name, ta.AvlBalance FROM AppUser u
JOIN TradingAccount ta ON u.UserId = ta.UserId
WHERE u.KycStatus != 'Verified' AND ta.AvlBalance > 0;
-- 13. Consolidated Financial IDs
-- Creates a master list mapping every User ID to their specific Trading and Demat account
-- numbers.
SELECT u.UserId, ta.TradingAccId, da.DematAccId
FROM AppUser u
LEFT JOIN TradingAccount ta ON u.UserId = ta.UserId
LEFT JOIN DematAccount da ON u.UserId = da.UserId;
-- 14. Simple Margin Calculation (20% of Portfolio Value)
-- Estimates a "borrowing limit" for Amit (U1) equal to 20% of his total portfolio's market value.
SELECT u.UserId, u.Name, SUM(ph.Current_Quantity_Held * md.DailyHigh) * 0.20 AS
Calculated_Margin
FROM AppUser u
JOIN DematAccount da ON u.UserId = da.UserId
JOIN Portfolio_Holds ph ON da.DematAccId = ph.DematAccId
JOIN ( SELECT DISTINCT ON (Ticker_Symbol) Ticker_Symbol, DailyHigh
FROM MarketData
ORDER BY Ticker_Symbol, TimeStamp DESC ) md ON ph.Ticker_Symbol =
md.Ticker_Symbol
WHERE u.UserId = 'U1' GROUP BY u.UserId, u.Name;
-- Scenario 2: Trade Execution & Order Management
-- 1. Pending Sell Orders
-- Lists all "Sell" requests that have been placed but are not yet executed or completed.
SELECT * FROM Orders WHERE Order_Type = 'SELL' AND Status = 'Pending';
-- 2. Trade-to-Order Mapping
-- Connects a specific order (O3) to its final execution details like price and exact time.
SELECT o.Order_ID, t.Execution_Price, t.Execution_Time
FROM Orders o JOIN Trade t ON o.Order_ID = t.Order_ID WHERE o.Order_ID = 'O3';
-- 3. Slippage Analysis (Price paid > Price requested)
-- Finds "Buy" trades where the final price paid was higher than the user's initial requested price.
SELECT t.Trade_ID, o.Price as Requested, t.Execution_Price as Actual
FROM Trade t JOIN Orders o ON t.Order_ID = o.Order_ID
WHERE t.Execution_Price > o.Price AND o.Order_Type = 'BUY';
-- 4. High-Volume Trades
-- Filters for specific trade executions where more than 10 shares changed hands in a single go.
SELECT * FROM Trade WHERE Execution_Qty > 10;
-- 5. Daily Transaction Volume
-- Sums up the total amount of successful cash deposits and withdrawals made today.
SELECT SUM(Amount) FROM Financial_Transaction
WHERE Status = 'Success' AND TimeStamp::DATE = CURRENT_DATE;
-- 6. Recent Activity for U2
-- Shows the 5 most recent stock trades performed by user Riya (U2).
SELECT t.* FROM Trade t
JOIN DematAccount da ON t.DematAccId = da.DematAccId
WHERE da.UserId = 'U2' ORDER BY Execution_Time DESC LIMIT 5;
-- 7. Order Distribution
-- Counts how many "Buy" vs. "Sell" orders exist in the entire system's history.
SELECT Order_Type, COUNT(*) FROM Orders GROUP BY Order_Type;
-- 8. Trade History with Tickers
Generates a log of every trade showing the specific stock symbol, quantity, and price.
SELECT t.Trade_ID, o.Ticker_Symbol, t.Execution_Qty, t.Execution_Price
FROM Trade t JOIN Orders o ON t.Order_ID = o.Order_ID;
-- 9. Average Buy Price for RELI (U2)
-- Calculates the average price Riya (U2) has paid for Reliance (RELI) across all her different buy
--orders.
SELECT AVG(Execution_Price) FROM Trade t
JOIN Orders o ON t.Order_ID = o.Order_ID
JOIN DematAccount da ON t.DematAccId = da.DematAccId
WHERE o.Ticker_Symbol = 'RELI' AND o.Order_Type = 'BUY' AND da.UserId = 'U2';
-- 10. Settlement Audit
-- Maps every trade back to its demat account and stock ticker for auditing purposes.
SELECT t.Trade_ID, t.DematAccId, o.Ticker_Symbol
FROM Trade t JOIN Orders o ON t.Order_ID = o.Order_ID;
-- 11. Cash Flow Summary
-- Calculates the "Net Flow" (Deposits minus Withdrawals) for every account based only on
-- successful transfers.
SELECT ft.TradingAccId,
SUM(CASE WHEN ft.Transaction_Type = 'Deposit' THEN ft.Amount ELSE -ft.Amount END)
as Net_Verified_Flow
FROM Financial_Transaction ft
JOIN TradingAccount ta ON ft.TradingAccId = ta.TradingAccId
JOIN LinkedBankAccount lb ON ft.BankAccountNo = lb.BankAccountNo
WHERE lb.UserId = ta.UserId -- Validation logic
AND ft.Status = 'Success'
GROUP BY ft.TradingAccId;
-- 12. Largest Trade of the Day
-- Identifies the single most expensive trade (Quantity × Price) that occurred during the current day.
SELECT Trade_ID, (Execution_Qty * Execution_Price) as Volume_Value
FROM Trade
WHERE Execution_Time::DATE = CURRENT_DATE
ORDER BY Volume_Value DESC LIMIT 1;
-- 13. SBI Transaction Logs
-- Specifically tracks all money transfers that moved through State Bank of India (SBI) accounts.
SELECT ft.* FROM Financial_Transaction ft
JOIN TradingAccount ta ON ft.TradingAccId = ta.TradingAccId
JOIN LinkedBankAccount lb ON ft.BankAccountNo = lb.BankAccountNo
WHERE lb.BankName = 'SBI' AND lb.UserId = ta.UserId;
-- 14. Top Trading Tickers
-- Ranks the stocks on the platform by the frequency of trades (most popular to least popular).
SELECT o.Ticker_Symbol,
COUNT(t.Trade_ID) as Trade_Count FROM Orders o
JOIN Trade t ON o.Order_ID = t.Order_ID GROUP BY o.Ticker_Symbol
ORDER BY Trade_Count DESC;
-- Scenario 3: Market Analytics & Watchlists
-- 1. Daily Gainers (>10% volatility)
-- Finds stocks that have seen high price swings (more than 10%) between their daily high and low.
SELECT Ticker_Symbol FROM MarketData
WHERE (DailyHigh - DailyLow) / DailyLow > 0.10;
-- 2. Volume Spikes
-- Identifies stocks currently trading at volumes significantly higher than their own historical
-- average.
SELECT m1.Ticker_Symbol, m1.Volume
FROM MarketData m1 WHERE m1.Volume > ( SELECT AVG(m2.Volume)
FROM MarketData m2 WHERE m1.Ticker_Symbol = m2.Ticker_Symbol );
-- 3. Specific Watchlist Content
-- Lists all the stock symbols currently being tracked in the "Energy Focus" watchlist.
SELECT Ticker_Symbol FROM Watchlist_Contains wc
JOIN Watchlist w ON wc.Watchlist_ID = w.Watchlist_ID
WHERE w.Watchlist_Name = 'Energy Focus';
-- 4. Sector Performance (Avg Price)
-- Calculates the average trading price for all companies within specific sectors (e.g., Finance vs.
-- Healthcare).
SELECT c.Sector, AVG(md.DailyHigh)
FROM MarketData md
JOIN Financial_Instruments fi ON md.Ticker_Symbol = fi.Ticker_Symbol
JOIN Company c ON fi.CompanyName = c.CompanyName GROUP BY c.Sector;
-- 5. Market Volatility (Latest Spread)
-- Shows the "Spread" (difference between High and Low prices) for every stock based on the
-- latest data.
SELECT DISTINCT ON (Ticker_Symbol)
 Ticker_Symbol,
 (DailyHigh - DailyLow) as Spread
FROM MarketData
ORDER BY Ticker_Symbol, TimeStamp DESC;
-- 6. Empty Watchlists
-- Finds user-created watchlists that don't actually have any stocks saved in them yet.
SELECT Watchlist_ID, Watchlist_Name
FROM Watchlist WHERE Watchlist_ID NOT IN (SELECT Watchlist_ID
FROM Watchlist_Contains);
-- 7. Historical Lows (7 days)
-- Finds the lowest price Infosys (INFY) has touched at any point in the last 7 days.
SELECT MIN(DailyLow) FROM MarketData
WHERE Ticker_Symbol = 'INFY' AND TimeStamp > NOW() - INTERVAL '7 days';
-- 8. NSE Stock Catalogz
-- Lists every company and ticker symbol specifically traded on the National Stock Exchange
-- (NSE).
SELECT Ticker_Symbol, CompanyName FROM Financial_Instruments
WHERE Exchange = 'NSE' AND Instrument_Type = 'Stock';
-- 9. Max Volume Ticker
-- Identifies the single stock that has the highest trading activity (volume) in the database.
SELECT Ticker_Symbol
FROM MarketData ORDER BY Volume DESC LIMIT 1;
-- 10. Stable Stocks (<1% spread)
-- Filters for "quiet" stocks where the price hasn't fluctuated more than 1% during the day.
SELECT Ticker_Symbol FROM MarketData
WHERE (DailyHigh - DailyLow)/DailyHigh < 0.01;
-- 11. High Volume / Low Price
-- Flags "Penny Stocks" or cheaper stocks (under 3000) that are currently seeing massive trading
-- activity.
SELECT * FROM MarketData WHERE Volume > 100000 AND DailyHigh < 3000;
-- 12. Exchange Distribution
-- Breaks down how many financial instruments are listed on the NSE versus other exchanges.
SELECT Exchange, COUNT(*) FROM Financial_Instruments GROUP BY Exchange;
-- 13. 7-Day History Export
-- Pulls a full chronological price and volume report for TCS over the past week for charting.
SELECT * FROM MarketData
WHERE Ticker_Symbol = 'TCS' AND TimeStamp > NOW() - INTERVAL '7 days'
ORDER BY TimeStamp DESC;