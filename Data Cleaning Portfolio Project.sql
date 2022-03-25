/*

Cleaning Data In SQL Queries - by Daniel Reid

*/

Select * From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------
-- STANDARDIZE DATE FORMAT FROM DATE-TIME TO DATE

Select SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)

-------------------------------------------------------------------------------------------

-- Populate Property Address Data 

Select *
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null;
order by [UniqueID ]

Select A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
From NashvilleHousing as A 
JOIN NashvilleHousing as B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ]<> B.[UniqueID ]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress= ISNULL(A.PropertyAddress,B.PropertyAddress)
From NashvilleHousing as A 
JOIN NashvilleHousing as B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ]<> B.[UniqueID ]
WHERE A.PropertyAddress is null

-----------------------------------------------------------------------------------------------------

-- Breaking Out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as ADDRESS
From
PortfolioProject.dbo.NashvilleHousing 


Alter Table NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing


/*
Simplier Way Of Splitting Address Using Owner Address
*/

Select OwnerAddress
FROM 
PortfolioProject.dbo.NashvilleHousing

-- ParseName Was Used This Way Because it Is Only Useful With Periods '.'

Select 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2) as City,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1) as State
FROM 
PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3) 


Alter Table NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2) 


Alter Table NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1) 


Select *
From
PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------

-- Change Y and N as Yes and No in "Solid as Vacant Field"


Select SoldAsVacant
From
PortfolioProject.dbo.NashvilleHousing

Select Distinct SoldAsVacant, count(SoldAsVacant) as HowMany
From
PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2
-- There are more Yes and No than N and Y

Select SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END
From
PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END


--------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Delete 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------
--DELETE UNUSED COLUMNS

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
