select *
from dbo.Nashvillehousing

--standardize date format

Alter Table Nashvillehousing
Add SaleDateConverted Date;

Update Nashvillehousing
Set SaleDateConverted = convert(Date,SaleDate)

select SaleDateConverted, convert(Date,SaleDate)
from dbo.Nashvillehousing

--populate property address data
select *
from Nashvillehousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashvillehousing a
join Nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashvillehousing a
join Nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--breaking out address into individual columns
select PropertyAddress
from Nashvillehousing

select 
substring(PropertyAddress, 1, charindex(',' , PropertyAddress)-1) as Address
, substring(PropertyAddress, charindex(',' , PropertyAddress)+1, Len (PropertyAddress)) as Address
from Nashvillehousing

Alter Table Nashvillehousing
Add PropertySPlitAddress nvarchar(255);

Update Nashvillehousing
Set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',' , PropertyAddress)-1)

Alter Table Nashvillehousing
Add PropertSplitCity nvarchar(255);

Update Nashvillehousing
Set PropertySplitCity = substring(PropertyAddress, charindex(',' , PropertyAddress)+1, Len (PropertyAddress))

select *
from Nashvillehousing


select OwnerAddress
from Nashvillehousing
 
select
PARSENAME(replace(OwnerAddress,',', '.') ,3)
,PARSENAME(replace(OwnerAddress,',', '.') ,2)
,PARSENAME(replace(OwnerAddress,',', '.') ,1)
from Nashvillehousing

Alter Table Nashvillehousing
Add OwnerSplitAddress nvarchar(255);

Update Nashvillehousing
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',', '.') ,3)

Alter Table Nashvillehousing
Add OwnerSplitCity nvarchar(255);

Update Nashvillehousing
Set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',', '.') ,2)

Alter Table Nashvillehousing
Add OwnerSplitState nvarchar(255);

Update Nashvillehousing
Set OwnerSplitState = PARSENAME(replace(OwnerAddress,',', '.') ,1)

 select *
 from Nashvillehousing

--change Y and N to 'yrs' and 'no' in 'Sold as Vacant' field
select distinct (SoldAsVacant), count (SoldAsVacant)
from Nashvillehousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'YES'
	 when SoldAsVacant = 'N' then 'NO'
	 else SoldAsVacant
	 end
from Nashvillehousing

update Nashvillehousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'YES'
	 when SoldAsVacant = 'N' then 'NO'
	 else SoldAsVacant
	 end

--remove duplicates

with RowNumCTE as (
select *,
	row_number () over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				   UniqueID
				   ) row_num
from Nashvillehousing
)
delete
from RowNumCTE
where row_num > 1

with RowNumCTE as (
select *,
	row_number () over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				   UniqueID
				   ) row_num
from Nashvillehousing
)
select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress

--delete unused columns
alter table Nashvillehousing
drop column OwnerAddress,TaxDistrict, PropertyAddress

alter table Nashvillehousing
drop column SaleDate

select * 
from Nashvillehousing