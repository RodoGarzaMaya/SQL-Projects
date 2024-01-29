Select * 
FROM PortfolioProject.dbo.NashvilleHousing

-- Standarize Date Format

Select SaleDateConverted, Convert(Date,SaleDate) 
FROM PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

-------------------------------------------------------------------------

-- Populate Property Address Data

Select *
FROM PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, A.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelID= b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelID= b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

-------------------------------------------------------------------------------------------

-- Breaking out Address into individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------

-- Split OwnerAddress

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1);

-----------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by 
				UniqueID
			) row_num
From PortfolioProject..NashvilleHousing
)
DELETE 
From RowNumCTE
Where row_num > 1 
--Order by PropertyAddress

-----------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate