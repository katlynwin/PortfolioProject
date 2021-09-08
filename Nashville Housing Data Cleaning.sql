------Cleaning Data in SQL Queries------

SELECT * 
FROM j74307_kitkat.dbo.NashvilleHousing

--standardizing date format---------------------------------------------------------------------------------------------------------------------------

SELECT SaleDate
	,CONVERT(Date, SaleDate)
FROM j74307_kitkat.dbo.NashvilleHousing

UPDATE j74307_kitkat.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--populate property address data----------------------------------------------------------------------------------------------------------------------

SELECT *
FROM j74307_kitkat.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--note: ParcelID is unique for each property address

SELECT a.ParcelID
	,a.PropertyAddress
	,b.ParcelID
	,b.PropertyAddress
	,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM j74307_kitkat.dbo.NashvilleHousing as a
JOIN j74307_kitkat.dbo.NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM j74307_kitkat.dbo.NashvilleHousing as a
JOIN j74307_kitkat.dbo.NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--breaking out address into individual columns (addres, city, state)----------------------------------------------------------------------------------

SELECT PropertyAddress
FROM j74307_kitkat.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM j74307_kitkat.dbo.NashvilleHousing

ALTER TABLE j74307_kitkat.dbo.NashvilleHousing
ADD PropertySplitAddress VARCHAR(255)

UPDATE j74307_kitkat.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE j74307_kitkat.dbo.NashvilleHousing
ADD PropertySplitCity VARCHAR(50)

UPDATE j74307_kitkat.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



SELECT OwnerAddress
FROM j74307_kitkat.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address
FROM j74307_kitkat.dbo.NashvilleHousing

ALTER TABLE j74307_kitkat.dbo.NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255)

UPDATE j74307_kitkat.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE j74307_kitkat.dbo.NashvilleHousing
ADD OwnerSplitCity VARCHAR(50)

UPDATE j74307_kitkat.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE j74307_kitkat.dbo.NashvilleHousing
ADD OwnerSplitState VARCHAR(50)

UPDATE j74307_kitkat.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in "Sold as Vacant" field----------------------------------------------------------------------------------------------

SELECT DISTINCT(SoldAsVacant)
	,COUNT(SoldAsVacant)
FROM j74307_kitkat.dbo.NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant
	,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM j74307_kitkat.dbo.NashvilleHousing

UPDATE j74307_kitkat.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

--remove duplicates-----------------------------------------------------------------------------------------------------------------------------------

WITH RowNumCTE AS (
SELECT * 
	,ROW_NUMBER() OVER(
		PARTITION BY ParcelID
					,PropertyAddress
					,SalePrice
					,SaleDate
					,LegalReference
					ORDER BY UniqueID) AS row_num
FROM j74307_kitkat.dbo.NashvilleHousing
--ORDER BY ParcelID
)

DELETE FROM RowNumCTE
WHERE row_num > 1




