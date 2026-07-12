INSERT INTO Company VALUES ('TCS','Technology'), ('Reliance','Energy'),
('Infosys','Technology'), ('HDFC','Finance'), ('SunPharma','Healthcare'),
('TataMotors','Automobile'), ('AdaniGreen', 'Energy'), ('ONGC', 'Energy');
INSERT INTO Financial_Instruments VALUES ('TCS','Stock','NSE','TCS'),
('RELI','Stock','NSE','Reliance'), ('INFY','Stock','NSE','Infosys'), ('HDFC','Stock','NSE','HDFC'),
('SUNP','Stock','NSE','SunPharma'), ('TATM','Stock','NSE','TataMotors'),
('ADANIG','Stock','NSE','AdaniGreen'), ('ONGC','Stock','NSE','ONGC');
INSERT INTO AppUser VALUES
('U1','Amit','amit@mail.com','1111','Delhi','PAN1','Verified'),
('U2','Riya','riya@mail.com','2222','Mumbai','PAN2','Verified'),
('U3','Raj','raj@mail.com','3333','Ahmedabad','PAN3','Verified'),
('U4','Vikram','vikram@mail.com','4444','Mumbai','PAN4','Pending'),
('U5','Sania','sania@mail.com','5555','Delhi','PAN5','Verified'), ('U6','Jay',
'null@mail.com','6666','Pune','PAN6','Verified');
INSERT INTO DematAccount VALUES ('D1','NSDL','2022-01-01','U1'), ('D2','CDSL','2022-
01-01','U2'), ('D3','NSDL','2023-01-01','U3'), ('D4','CDSL','2024-01-01','U4'),
('D5','NSDL','2025-01-01','U5'), ('D6','NSDL','2025-01-01','U6');
INSERT INTO TradingAccount VALUES ('T1',50000,'U1'), ('T2',30000,'U2'), ('T3',70000,'U3'),
('T4',15000,'U4'), ('T5',0, 'U5'), ('T6',1000,'U6');
INSERT INTO LinkedBankAccount VALUES ('BA1', 'HDFC001', 'HDFC Bank', TRUE, 'U1'),
('BA2', 'ICIC002', 'ICICI Bank', TRUE, 'U2'), ('BA3', 'SBIN003', 'SBI', TRUE, 'U3'), ('BA4',
'KKBK004', 'Kotak Bank', TRUE, 'U4'), ('BA5', 'AXIS005', 'Axis Bank', TRUE, 'U5'), ('BA6',
'BARB006', 'Bank of Baroda', TRUE, 'U6');
INSERT INTO Portfolio_Holds VALUES ('D1','TCS',10), ('D1','RELI',65), ('D1','SUNP',2),
('D1','TATM',3), ('D2','RELI',8), ('D2','TCS',4), ('D3','INFY',5), ('D4','RELI',5);
INSERT INTO Orders VALUES ('O3','BUY',1500,'Executed',15,NOW(),'T3','INFY'),
('O4','BUY',2800,'Executed',12,NOW(),'T2','RELI'),
('O5','SELL',3550,'Pending',5,NOW(),'T1','TCS'), ('O10','BUY',3000,'Pending',10,NOW() -
INTERVAL '3 days','T1','RELI'), ('O11','BUY',2600,'Executed',5,NOW(),'T1','RELI'),
('O12','BUY',100,'Cancelled',10,NOW() - INTERVAL '2 hours','T2','TCS');
INSERT INTO Trade VALUES ('TR2',15,1485,NOW() - INTERVAL '1 hour','O3','D3'),
('TR11',5,2700,NOW() - INTERVAL '30 min','O11','D1'), ('TR12',10,2800,NOW(),'O4','D2');
INSERT INTO MarketData (Ticker_Symbol, TimeStamp, DailyHigh, DailyLow, CurrPrice,
Volume) VALUES ('TCS',NOW(),3550,3300,3450,120000),
('RELI',NOW(),2550,2300,2400,90000), ('HDFC',NOW(),1500,1495,1498,50000),
('SUNP',NOW(),500,480,490,200000), ('INFY',NOW() - INTERVAL '1 day', 1600, 1550, 1575,
40000);
INSERT INTO MarketData VALUES
-- TCS
('TCS', NOW() - INTERVAL '3 days', 3500, 3200, 3300, 100000),
('TCS', NOW() - INTERVAL '2 days', 3550, 3300, 3450, 150000),
-- RELI
('RELI', NOW() - INTERVAL '3 days', 2500, 2200, 2300, 80000),
('RELI', NOW() - INTERVAL '2 days', 2550, 2300, 2400, 95000),
-- INFY
('INFY', NOW() - INTERVAL '3 days', 1580, 1500, 1520, 20000),
('INFY', NOW() - INTERVAL '2 days', 1600, 1550, 1575, 80000),
-- SUNP
('SUNP', NOW() - INTERVAL '2 days', 495, 470, 480, 210000),
-- HDFC
('HDFC', NOW() - INTERVAL '2 days', 1490, 1470, 1480, 30000),
('HDFC', NOW() - INTERVAL '1 day 2 hours', 1500, 1480, 1490, 90000);
INSERT INTO Watchlist VALUES ('W1', 'Energy Focus', 'U1'), ('W2', 'Tech Giants', 'U2'),
('W3', 'Empty Watchlist', 'U3');
INSERT INTO Watchlist_Contains VALUES ('W1', 'RELI'), ('W1', 'ADANIG'), ('W1', 'ONGC'),
('W2', 'TCS'), ('W2', 'INFY'), ('W2', 'RELI'), ('W2', 'HDFC');
INSERT INTO Financial_Transaction VALUES
('TX10','Withdraw',100,'UPI','Success',NOW(),'T3','BA3'),
('TX11','Withdraw',100,'UPI','Success',NOW(),'T3','BA3'),
('TX12','Withdraw',100,'UPI','Success',NOW(),'T3','BA3'),
('TX13','Withdraw',100,'UPI','Success',NOW(),'T3','BA3'),
('TX14','Deposit',15000,'NetBanking','Pending',NOW(),'T2','BA2');
