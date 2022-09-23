/*

Cleaning Data in SQL Queries

*/

Select * 
from PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format
Update NashvilleHousing
Set SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted =CONVERT(date, SaleDate)

Select SaleDate, SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing
----------------------------------------------------------------------------------------------------
-- Populate Property Address Data

Select *
from PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address, 
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

Select * 
From PortfolioProject.dbo.NashvilleHousing 

-------------------------------------------------------------------------------------------------------
--Breaking out OwnerAddress into Individual Columns (Street, City, State)

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing 

Select
PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 1) AS Street
, PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 2) AS City
, PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 3) AS State
From PortfolioProject.dbo.NashvilleHousing 


ALTER TABLE NashvilleHousing
Add OwnerSplitStreet Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitStreet = PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 1)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 3)

Select *
From PortfolioProject.dbo.NashvilleHousing 

--------------------------------------------------------------------------------------------------
-- Change Y and N into Yes and No in the column "Sold as Vacant"

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2


Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing 

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

------------------------------------------------------------------------------------------------------
--Remove Duplicates   "Very Critical Action and need Approval"

WITH ROWNUMCTE AS(
Select * , 
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY UniqueID
			   ) row_num
From PortfolioProject.dbo.NashvilleHousing 
)

/*
DELETE
From ROWNUMCTE
Where row_num > 1
*/
SELECT *
From ROWNUMCTE
Where row_num > 1
Order By PropertyAddress

--------------------------------------------------------------------------------------------------
--Delete Unused Columns  "Very Critical Action and need Approval"

Select *
From PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict , PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate