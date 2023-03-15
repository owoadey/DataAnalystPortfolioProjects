
--Selecting data for cleaning


select *
from NashvilleHousing


--Standardize Data Format


select SaleDateConverted, convert(date,SaleDate)
from NashvilleHousing


Alter Table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

--property address population
select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking address into individual columns (Address , City, State)
select PropertyAddress
from NashvilleHousing
--where a.PropertyAddress is null
--order by ParcelID


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1,len(PropertyAddress)) as Address
from NashvilleHousing

Alter Table NashvilleHousing
add PropertySplitAddress Nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)

Alter Table NashvilleHousing
add PropertySplitCity Nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1,len(PropertyAddress))



--Splitting owner address
select OwnerAddress
from NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress,',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)
from NashvilleHousing

Alter Table NashvilleHousing
add OwnerSplitAddress Nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)

Alter Table NashvilleHousing
add OwnerSplitCity Nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)

Alter Table NashvilleHousing
add OwnerSplitState Nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)

--Change Y and N to Yes and No on "Solad as vacant" field
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'YES'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'YES'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

--Remove duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
					UniqueID
					) row_num
	
from NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num > 1


--Delete unused columns
select *
from NashvilleHousing

Alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table NashvilleHousing
drop column SaleDate






