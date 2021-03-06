/*
http://www.sqlservercentral.com/articles/T-SQL/62159/
*/

CREATE TABLE [dbo].[Items](
	[ItemId] [int] NOT NULL,
	[Item] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Items] PRIMARY KEY CLUSTERED 
(
	[ItemId] ASC
))
GO

CREATE TABLE [dbo].[PriceHistory](
	[ItemId] [int] NOT NULL,
	[PriceStartDate] [datetime] NOT NULL,
	[Price] [decimal](10, 2) NOT NULL,
 CONSTRAINT [PK_PriceHistory] PRIMARY KEY CLUSTERED 
(
	[ItemId] ASC,
	[PriceStartDate] ASC
))
GO
ALTER TABLE [dbo].[PriceHistory]  WITH CHECK ADD  CONSTRAINT [FK_PriceHistory_Items] FOREIGN KEY([ItemId])
REFERENCES [dbo].[Items] ([ItemId])

GO

CREATE VIEW [dbo].[PriceCompare] AS 

WITH PriceCompare AS 
(
SELECT i.Item, ph.ItemId, ph.PriceStartDate, ph.Price,
ROW_NUMBER() OVER (Partition BY ph.ItemId ORDER BY PriceStartDate) AS rownum 
FROM Items i INNER JOIN PriceHistory ph 
ON i.ItemId = ph.ItemId) 


SELECT currow.Item, prevrow.Price AS OldPrice, currow.Price AS RangePrice, currow.PriceStartDate AS StartDate, nextrow.PriceStartDate AS EndDate 
FROM PriceCompare currow 
LEFT JOIN PriceCompare nextrow 
	ON currow.rownum = nextrow.rownum - 1
	AND currow.ItemId = nextrow.ItemId
LEFT JOIN PriceCompare prevrow
	ON currow.rownum = prevrow.rownum + 1
	AND currow.ItemId = prevrow.ItemId

 
GO
INSERT INTO Items VALUES (1, 'vacuum cleaner')
INSERT INTO Items VALUES (2, 'washing machine')
INSERT INTO Items VALUES (3, 'toothbrush')

INSERT INTO PriceHistory VALUES (1,'2004-03-01',250)
INSERT INTO PriceHistory VALUES (1,'2005-06-15',219.99)
INSERT INTO PriceHistory VALUES (1,'2007-01-03',189.99)
INSERT INTO PriceHistory VALUES (1,'2007-02-03',200.00)
INSERT INTO PriceHistory VALUES (2,'2006-07-12',650.00)
INSERT INTO PriceHistory VALUES (2,'2007-01-03',550.00)
INSERT INTO PriceHistory VALUES (3,'2005-01-01',1.99)
INSERT INTO PriceHistory VALUES (3,'2006-01-01',1.79)
INSERT INTO PriceHistory VALUES (3,'2007-01-01',1.59)
INSERT INTO PriceHistory VALUES (3,'2008-01-01',1.49)
