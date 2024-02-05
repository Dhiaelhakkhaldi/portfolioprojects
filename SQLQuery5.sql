--- Cleaning Data


--- Changing SaleDate format
Select SaleDate, CAST(SaleDate AS date) 
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date

SELECT *
FROM NashvilleHousing


--- Populate empty property addresses
SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL


SELECT A.PropertyAddress, A.ParcelID, B.PropertyAddress, B.ParcelID, 
ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
     ON A.ParcelID = B.ParcelID AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
     ON A.ParcelID = B.ParcelID AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL


--- Seperate PropertyAddress to different columns(address,city, state)
SELECT PropertyAddress, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) City
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL





ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 


SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing


--- Changing displayed values in SoldAsVacant from Y to Yes, and from N to No
SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant



SELECT SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END SoldAsVacantUpdated, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant


UPDATE NashvilleHousing
SET SoldAsVacant = (CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END)


--- Getting rid of duplicates
WITH DuplicateRow AS
(SELECT *, ROW_NUMBER() OVER (PARTITION BY PARCELID,
                                           PropertyAddress,
										   SalePrice,
										   SaleDate,
										   LegalReference
										   ORDER BY UniqueID) 
										   RowNum
FROM NashvilleHousing)

SELECT * 
FROM DuplicateRow
WHERE RowNum > 1


--- Deleting unnecessary columns
ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict, HalfBath

SELECT * 
FROM NashvilleHousing
