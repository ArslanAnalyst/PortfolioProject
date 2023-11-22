--Cleaning Data in Sql Query

select *
from PortfolioProject..NashvillHousing

----------------------------------------------------------

--Standardrize Date Format

select SaleDateConverted, CONVERT(date, SaleDate)
from PortfolioProject..NashvillHousing


update NashvillHousing
set SaleDate = CONVERT(date, SaleDate)

alter table NashvillHousing
add SaleDateConverted date;

update NashvillHousing
set SaleDateConverted = CONVERT(date, SaleDate)


----------------------------------------------------------

--populate property address data 

select *
from PortfolioProject..NashvillHousing 
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvillHousing a
join PortfolioProject..NashvillHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvillHousing a
join PortfolioProject..NashvillHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------

--Break out Address into individual column (Address, City, State)

select PropertyAddress
from PortfolioProject..NashvillHousing 
--where PropertyAddress is null
--order by ParcelID


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address 
from PortfolioProject..NashvillHousing 


alter table NashvillHousing
add PropertySplitAddress nvarchar(255)

update NashvillHousing
set PropertySplitAddress = CONVERT(date, SaleDate)

alter table NashvillHousing
add PropertySplitCity nvarchar(255)

update NashvillHousing
set PropertySplitCity = CONVERT(date, SaleDate)


select * 
from PortfolioProject..NashvillHousing

select OwnerAddress
from PortfolioProject..NashvillHousing


select 
PARSENAME(replace(OwnerAddress, ',', '.'),3)
, PARSENAME(replace(OwnerAddress, ',', '.'), 2)
, PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvillHousing


alter table NashvillHousing
add OwnerSplitAddress nvarchar(255)

update NashvillHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'),3)

alter table NashvillHousing
add OwnerSplitCity nvarchar(255)

update NashvillHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)



alter table NashvillHousing
add OwnerSplitState nvarchar(255)

update NashvillHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


-------------------------------------------------------------------------

--change y and N in 'Sold As Vacant' field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvillHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant  end
		from NashvillHousing

update  NashvillHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant  end
----------------------------------------------------

--Remove Duplicates

select * 
from NashvillHousing


With RowNumCTE As
(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by 
	UniqueID
	) row_num
from NashvillHousing
)

Select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress

------------------------------------------------------------------

--Delete Unusual Coloumn


select * 
from NashvillHousing

Alter Table NashvillHousing
drop column ownerAddress, TaxDistrict, PropertyAddress

Alter Table NashvillHousing
drop column SaleDate