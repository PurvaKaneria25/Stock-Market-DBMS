# BigBull: Stock Trading & Portfolio Management Database System

BigBull is a comprehensive relational database system designed to power a modern stock trading and portfolio management platform. It tracks user profiles, multi-account structures (Trading, Demat, and Bank accounts), real-time market data, order management, historical trade execution, customized watchlists, and secure financial transactions.

The schema is built to ensure strict data integrity, high compliance mapping, and real-time query performance.

---

## 🏢 System Architecture & Design

The database design handles high-frequency market updates and critical trade executions while maintaining full transactional consistency.

### 📐 Diagrams
* **Entity-Relationship (ER) Diagram:** Illustrates the core business entities, their descriptive attributes, and their semantic relationships (such as many-to-many mappings for watchlists and portfolios).
* **Relational Schema Map:** Highlights structural foreign key paths, composite primary keys, and constraint paths.

---

## 🗄️ Database Schema Breakdown

The architecture is categorized into 7 distinct core modules:

### 1. Base Tables
* **`AppUser`**: Stores user demographic profiles, contact data, and compliance verification markers (`KycStatus`: Verified, Pending, Unverified).
* **`Company`**: High-level directory organizing listed corporate entities into market sectors (e.g., Technology, Energy, Finance).

### 2. Account Infrastructure
* **`DematAccount`**: Tracks the user's regulatory depository storage (NSDL/CDSL) where securities are legally settled.
* **`TradingAccount`**: Holds the liquid cash assets (`AvlBalance`) required to route and back market orders.
* **`LinkedBankAccount`**: Manages external banking networks linked to user accounts for seamless funds routing.

### 3. Market Layer
* **`Financial_Instruments`**: Catalog of listed instruments (Stocks, ETFs, etc.), their respective symbols, and the listing exchange (e.g., NSE).
* **`MarketData`**: Chronological time-series ledger capturing price movements (`DailyHigh`, `DailyLow`, `CurrPrice`) and trading volumes.

### 4. Portfolio Management
* **`Portfolio_Holds`**: A direct registry tracking the exact real-time quantities of asset shares securely settled inside a user's Demat account.

### 5. Order & Trade Lifecycle
* **`Orders`**: Capture state log for requests (`BUY`/`SELL`) processing through states (`Pending`, `Executed`, `Cancelled`).
* **`Trade`**: The legal execution ledger mapping filled orders directly to specific target Demat accounts at finalized spot clearing prices.

### 6. Watchlist Customization
* **`Watchlist` & `Watchlist_Contains`**: Allow users to group, tag, and isolate selected ticker sets for dedicated performance observation.

### 7. Transaction Audit Log
* **`Financial_Transaction`**: Double-entry ledger documenting incoming deposits or outgoing fund withdrawals routing across linked banking lines.

---

## 🔍 Analytical & Operational Queries

The system comes equipped with robust analytical capabilities divided into core operational vectors:

### 💼 Portfolio & Wealth Management
* **User Net Worth:** Consolidates immediate liquid trading account cash balances with live-ish asset valuations extracted from time-series `MarketData` highs.
* **Sector Concentration & Exposure:** Evaluates asset exposure ratios across sectors (e.g., computing a user's exact percentage exposure to the Technology sector) to audit systemic risk.
* **Diversification Checks:** Flags advanced "power investors" holding active placements stretching across more than 3 distinct industrial verticals.

### 📈 Trading Operations & Liquidity Audits
* **Slippage Analysis:** Pinpoints execution anomalies where the final trade clearing price surpassed the original limit order request constraints on buy orders.
* **Cash Flow Reconciliation:** Audits transaction

### 📊 Market Discovery & Volume Alerts
* **Volatility Spikes:** Filters for active market tickers experiencing significant intrahour swings where:
  $$\frac{\text{DailyHigh} - \text{DailyLow}}{\text{DailyLow}} > 10\%$$
* **Volume Abnormalities:** Extracts assets showing unusual trading traction by isolating current volumes exceeding historical moving averages.
