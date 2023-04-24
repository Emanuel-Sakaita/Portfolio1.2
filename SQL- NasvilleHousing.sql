/*
Cleaning Data in SQL Queries
*/

SELECT*
FROM dbo.Sheet1$

--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT salesdateconverted, CONVERT(date, SaleDate)
FROM dbo.Sheet1$

--update dbo.Sheet1$
--SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE dbo.Sheet1$
ADD salesdateconverted date;

update dbo.Sheet1$
SET salesdateconverted = CONVERT(date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

SELECT PropertyAddress
FROM dbo.Sheet1$
--where PropertyAddress is not null
order by ParcelID

SELECT a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.Sheet1$ a 
JOIN dbo.Sheet1$ b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 

update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.Sheet1$ a 
JOIN dbo.Sheet1$ b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM dbo.Sheet1$
--where PropertyAddress is not null
--order by ParcelID

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM dbo.Sheet1$


ALTER TABLE dbo.Sheet1$
ADD propertysplitadress nvarchar(255);

update dbo.Sheet1$
SET propertysplitaddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE dbo.Sheet1$
ADD propertysplitcity nvarchar(255);

update dbo.Sheet1$
SET propertysplitcity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT*
FROM dbo.Sheet1$

ALTER TABLE dbo.Sheet1$
DROP COLUMN TaxDistrict;
--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT distinct (SoldAsVacant), COUNT(SoldAsVacant)
from dbo.Sheet1$
group by SoldAsVacant;

SELECT SoldAsVacant,
Case 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END 
FROM dbo.Sheet1$

UPDATE dbo.Sheet1$
SET SoldAsVacant = Case 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END 
FROM dbo.Sheet1$;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
With RowNumCTE as (
SELECT *, 
ROW_NUMBER () OVER (
PARTITION BY Parcelid,
			PropertyAddress,
			SaleDate,
			SalePrice,
			LegalReference 
			Order by uniqueid) row_num
FROM dbo.Sheet1$
--ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT*
FROM dbo.Sheet1$

