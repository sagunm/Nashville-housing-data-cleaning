-- Cleaning Data with SQL Queries*/ -- 

SELECT * 
FROM n_housing_data;

-- Change Date Format --

SELECT 
	SaleDate, 
    STR_TO_DATE(SaleDate, '%M %d, %Y')
FROM 
	n_housing_data;

UPDATE 
	n_housing_data
SET 
	SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');

-- SET SQL_SAFE_UPDATES = 1;

ALTER TABLE 
	n_housing_data
ADD `SaleDateConverted` Date;

UPDATE 
	n_housing_data
SET 
	SaleDateConverted = STR_TO_DATE(SaleDate, '%Y-%m-%d');

SELECT 
	SaleDateConverted
FROM 
	n_housing_data;

-- Populating Property Address data --

SELECT *
FROM 
	n_housing_data
WHERE 
	PropertyAddress = '' OR PropertyAddress IS NULL
ORDER BY 
	ParcelID;

SELECT 
	h1.UniqueID, h1.ParcelID, 
	h1.PropertyAddress, h2.UniqueID, 
	h2.ParcelID, h2.PropertyAddress
FROM 
	n_housing_data h1
JOIN 
	n_housing_data h2
ON 
	h1.ParcelID = h2.ParcelID
AND 
	h1.UniqueID != h2.UniqueID
WHERE 
	h2.PropertyAddress = '' OR h2.PropertyAddress IS NULL;

-- SET SQL_SAFE_UPDATES = 1;

UPDATE
    n_housing_data
SET
    ParcelID = CASE WHEN ParcelID = '' THEN NULL 
					ELSE ParcelID 
                    END,
    LandUse = CASE WHEN LandUse = '' THEN NULL 
				   ELSE LandUse 
                   END,
    PropertyAddress = CASE WHEN PropertyAddress = '' THEN NULL 
					  ELSE PropertyAddress 
                      END,
    SaleDate = CASE WHEN SaleDate = '' THEN NULL 
					ELSE SaleDate 
                    END,
    LegalReference = CASE WHEN LegalReference = '' THEN NULL 
						  ELSE LegalReference 
                          END,
    SoldAsVacant = CASE WHEN SoldAsVacant = '' THEN NULL 
						ELSE SoldAsVacant 
                        END,
    OwnerName = CASE WHEN OwnerName = '' THEN NULL 
					 ELSE OwnerName 
                     END,
    OwnerAddress = CASE WHEN OwnerAddress = '' THEN NULL 
						ELSE OwnerAddress 
                        END,
    Acreage = CASE WHEN Acreage = '' THEN NULL 
				   ELSE Acreage 
                   END,
    TaxDistrict = CASE WHEN TaxDistrict = '' THEN NULL 
					   ELSE TaxDistrict 
                       END,
    LandValue = CASE WHEN LandValue = '' THEN NULL 
					 ELSE LandValue 
                     END,
    BuildingValue = CASE WHEN BuildingValue = '' THEN NULL 
						 ELSE BuildingValue 
                         END,
    TotalValue = CASE WHEN TotalValue = '' THEN NULL 
					  ELSE TotalValue 
                      END,
    YearBuilt = CASE WHEN YearBuilt = '' THEN NULL 
					 ELSE YearBuilt 
                     END,
    Bedrooms = CASE WHEN Bedrooms = '' THEN NULL 
					ELSE Bedrooms 
                    END,
    FullBath = CASE WHEN FullBath = '' THEN NULL 
					ELSE FullBath 
                    END,
    HalfBath = CASE WHEN HalfBath = '' THEN NULL 
					ELSE HalfBath 
                    END;



/*
JOIN n_housing_data b
ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress);

FROM n_housing_data a
*/


UPDATE 
	n_housing_data a,
	n_housing_data b 
 SET 
	a.PropertyAddress = b.PropertyAddress
 WHERE
	a.PropertyAddress IS NULL
		AND a.ParcelID = b.ParcelID
		AND b.PropertyAddress is not null;

-- Breaking Address into diffrerent columns for Street Address and City -- 

SELECT 
	PropertyAddress
FROM 
	n_housing_data;

SELECT 
	SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
	SUBSTRING_INDEX(PropertyAddress, ',', -1) AS City
FROM 
	n_housing_data;


ALTER TABLE 
	n_housing_data
ADD 
	PropertyStreetAddress VARCHAR(255);
    
UPDATE
	n_housing_data
SET 
	PropertyStreetAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);
    

ALTER TABLE 
	n_housing_data
ADD 
	PropertyCity VARCHAR(255);
    
UPDATE
	n_housing_data
SET 
	PropertyCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);
    
    
SELECT 
	PropertyStreetAddress, PropertyCity
FROM 
	n_housing_data;
    
    
    
SELECT 
	OwnerAddress
FROM 
	n_housing_data;
    
SELECT 
	SUBSTRING_INDEX(OwnerAddress, ',', -1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1),
    SUBSTRING_INDEX(OwnerAddress, ',', 1)
FROM 
	n_housing_data;
    
    
ALTER TABLE 
	n_housing_data
ADD 
	OwnerStreetAddress VARCHAR(255);
    
UPDATE
	n_housing_data
SET 
	OwnerStreetAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);
    
ALTER TABLE 
	n_housing_data
ADD 
	OwnerCity VARCHAR(255);
    
UPDATE
	n_housing_data
SET 
	OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1);
    
ALTER TABLE 
	n_housing_data
ADD 
	OwnerState VARCHAR(255);
    
UPDATE
	n_housing_data
SET 
	OwnerState = SUBSTRING_INDEX(OwnerAddress, ',', -1);
    

-- Changing Y and N in Sold as Vacant to Yes and No -- 

SELECT 
	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM 
	n_housing_data
GROUP BY 
	SoldAsVacant
ORDER BY 2;

SELECT 
	SoldAsVacant,
    CASE WHEN SoldAsVacant = "Y" THEN "Yes"
		 WHEN SoldAsVacant = "N" THEN "No" 
         ELSE SoldAsVacant
         END
FROM 
	n_housing_data;

SET SQL_SAFE_UPDATES = 1;

UPDATE 
	n_housing_data
SET 
	SoldAsVacant = CASE WHEN SoldAsVacant = "Y" THEN "Yes"
						WHEN SoldAsVacant = "N" THEN "No" 
						ELSE SoldAsVacant
						END;


-- Removing Duplicates -- 

SELECT * 
FROM n_housing_data;

WITH RowNumCTE AS (
	SELECT *, 
		   ROW_NUMBER() OVER (
		   PARTITION BY ParcelID, PropertyAddress,
						SalePrice, SaleDate,
						LegalReference
						ORDER BY
							UniqueID
							) row_num
FROM n_housing_data
-- ORDER BY ParcelID
)
SELECT 
	COUNT(*), row_num
FROM 
	RowNumCTE
WHERE 
	row_num > 1
-- ORDER BY PropertyAddress;
GROUP BY 
	row_num;


WITH RowNumCTE AS (
	SELECT *, 
		   ROW_NUMBER() OVER (
		   PARTITION BY UniqueID, ParcelID, PropertyAddress,
						SalePrice, SaleDate,
						LegalReference
						ORDER BY
							UniqueID
							) row_num
FROM n_housing_data
-- ORDER BY ParcelID
)
SELECT 
	DISTINCT(row_num)
FROM 
	RowNumCTE
-- ORDER BY PropertyAddress;
GROUP BY 
	row_num;



WITH RowNumCTE AS (
	SELECT *, 
		   ROW_NUMBER() OVER (
		   PARTITION BY UniqueID, ParcelID, PropertyAddress,
						SalePrice, SaleDate,
						LegalReference
						ORDER BY
							UniqueID
							) row_num
FROM n_housing_data
ORDER BY ParcelID
)
SELECT 
	COUNT(*)
FROM 
	RowNumCTE
WHERE 
	row_num > 1
GROUP BY 
	row_num;

-- Removing Unused Columns

SELECT *
FROM n_housing_data;

ALTER TABLE 
	n_housing_data
DROP COLUMN 
	PropertyAddress;

