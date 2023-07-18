-- Tutorial_PortfolioProject_2_DataCleaningSQL

-- from Nashville Housing data on excel file

------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize date format 



Select SaleDateConverted, Convert(Date,SaleDate)
-- select saledate, convert(Date,saledate)
from PortfolioProject.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress
from PortfolioProject.NashvilleHousing
Where PropertyAddress is null 

Select *
from PortfolioProject.NashvilleHousing
-- Where PropertyAddress is null 
order by ParcelID

--self join
Select orig.ParcelID, orig.PropertyAddress, new.ParcelID, new.PropertyAddress, ISNULL(orig.PropertyAddress, new.PropertyAddress)
from PortfolioProject.NashvilleHousing as orig
join PortfolioProject.NashvilleHousing as new
    on orig.ParcelID = new.ParcelID
    and orig.[UniqueID] <> new.[UniqueID]
where orig.PropertyAddress is null

--if its null it doesnt show up on table
Update orig
Set PropertyAddress = ISNULL(orig.PropertyAddress, new.PropertyAddress)
From PortfolioProject.NashvilleHousing as orig 
join PortfolioProject.NashvilleHousing as new
    on orig.ParcelID = new.ParcelID
    and orig.[UniqueID] <> new.[UniqueID] 
where orig.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual columns (Address, city, state)

Select PropertyAddress
from PortfolioProject.NashvilleHousing
-- Where PropertyAddress is null 
-- order by ParcelID

-- -1 removes comma at end of address
select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
from PortfolioProject.NashvilleHousing


select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress)) as Address
from PortfolioProject.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress))

select *
from PortfolioProject.NashvilleHousing

select OwnerAddress
from PortfolioProject.NashvilleHousing


-- backwards, have to go 3,2,1 to get desired result
select 
parsename(replace(OwnerAddress, '', '.') , 1)
parsename(replace(OwnerAddress, '', '.') , 2)
parsename(replace(OwnerAddress, '', '.') , 3)
from PortfolioProject.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = parsename(replace(OwnerAddress, '', '.') , 3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = parsename(replace(OwnerAddress, '', '.') , 2) 

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = parsename(replace(OwnerAddress, '', '.') , 1)



select *
from PortfolioProject.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant 
, Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
       Else SoldAsVacant
       End 
From PortfolioProject.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
       Else SoldAsVacant
       End 


-------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

Select *,
    Row_Number() Over (
    partition by ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 Order by 
                   UniqueID
                   ) row_num 
From PortfolioProject.NashvilleHousing
order by ParcelID 


-- have to put it in a CTE

With RowNumCTE AS(
Select *,
    Row_Number() Over (
    partition by ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 Order by 
                   UniqueID
                   ) row_num 
From PortfolioProject.NashvilleHousing
-- order by ParcelID 
)
--Select * and then
Delete 
-- and then Select * again
From RowNumCTE
where row_num > 1
Order by PropertyAddress

-------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select * 
From PortfolioProject.NashvilleHousing

Alter Table PortfolioProject.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioProject.NashvilleHousing
Drop Column SaleDate












------------------------------------------------------------------------------------------------------------------------------------------------
































--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
