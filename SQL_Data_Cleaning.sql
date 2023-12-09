-- SQL_Data_Cleaning
-- Problem Statement (Business Task):

-- Collecting (importing) raw housing data to clean and transform with SQL to make it more usable for analysis.

-- Data source: https://www.kaggle.com/tmthyjames/nashville-housing-data

-- Project Task:

-- 1. Import data to DB browser for SQL Lite
-- 2. Standardize Sell date format
-- 3. Populate the property address data (populating blank)
-- 4. Breaking up address into individual columns (Separate address, state, and city)
-- 5. Adding key statements, from yes or no statements
-- 6. Deleting unused columns
-- 7. Removing duplicates

-- 1. Populate Property Address data
-- Select rows with null PropertyAddress
SELECT *
FROM Nashville
WHERE PropertyAddress IS NULL;

-- Identify rows with the same ParcelID and different PropertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) AS UpdatedAddress
FROM Nashville a
JOIN Nashville b ON a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

-- Update PropertyAddress with linked ParcelID if null
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a
JOIN Nashville b ON a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

-- Consulting decision:
-- For rows with null PropertyAddress, we used the linked PropertyAddress from the same ParcelID.

-- 2. Standardize Date Format
-- Note: The conversion might vary depending on the database. The following code assumes SQL Server syntax.
-- Import data to DB browser for SQL Lite, then perform the following updates:

-- Add a new column for the converted date
ALTER TABLE Nashville
ADD SaleDateConverted Date;

-- Update the new column with the converted date
UPDATE Nashville
SET SaleDateConverted = CAST(SaleDate AS Date);

-- Consulting decision:
-- Standardizing the SaleDate format to make it consistent and suitable for analysis.

-- 3. Breaking out Address into Individual Columns (Address, City, State)
-- Use substr to split PropertyAddress into Address and City
ALTER TABLE Nashville
ADD PropertySplitAddress Nvarchar(255);

UPDATE Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE Nashville
ADD PropertySplitCity Nvarchar(255);

UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Consulting decision:
-- Breaking down the PropertyAddress into separate columns (Address, City) for better analysis.

-- Similarly, split OwnerAddress into OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState

-- 4. Change Y and N to Yes and No in "Sold as Vacant" field
UPDATE Nashville
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

-- Consulting decision:
-- Standardizing 'SoldAsVacant' to 'Yes' or 'No' for clarity and consistency.

-- 5. Remove Duplicates then removing COLUMNS
-- Create a CTE to identify and remove duplicate rows
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
    FROM Nashville
)
DELETE FROM RowNumCTE WHERE row_num > 1;

-- Consulting decision:
-- Identifying and removing duplicate rows based on specific columns to maintain data integrity.

-- Delete unused columns
ALTER TABLE Nashville
DROP COLUMN TaxDistrict,
              PropertyAddress,
              SaleDate,
              OwnerAddress;
