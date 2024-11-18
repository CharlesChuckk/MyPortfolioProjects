select *
from [Ekoyo's Portfolio Projects]..[Nashville Housing]

--populating missing property address data
select*
from [Ekoyo's Portfolio Projects]..[Nashville Housing]
--where PropertyAddress is null
order by ParcelID

select x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress, ISNULL( x.PropertyAddress, y.PropertyAddress)
from [Ekoyo's Portfolio Projects]..[Nashville Housing] x
join [Ekoyo's Portfolio Projects]..[Nashville Housing] y
on x.ParcelID= y.ParcelID
and x.UniqueID <> y.UniqueID
--where x.PropertyAddress is null

update x
set PropertyAddress=  ISNULL( x.PropertyAddress, y.PropertyAddress)
from [Ekoyo's Portfolio Projects]..[Nashville Housing] x
join [Ekoyo's Portfolio Projects]..[Nashville Housing] y
on x.ParcelID= y.ParcelID
and x.UniqueID <> y.UniqueID
where x.PropertyAddress is null

--splitting PropertyAddress into individual columns (address, city,)
select PropertyAddress
from [Nashville Housing]

select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress)+1, LEN(Propertyaddress)) as Address
from [Nashville Housing]

alter table [Nashville Housing]
add PropertySplitAddress nvarchar(255);

update [Nashville Housing]
set PropertySplitAddress= SUBSTRING(propertyaddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table [Nashville Housing]
add PropertySplitCity nvarchar(255);

update [Nashville Housing]
set PropertySplitCity= SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress)+1, LEN(Propertyaddress))


--splitting OwnerAddress into individual columns (address, city, state)
select OwnerAddress
from [Ekoyo's Portfolio Projects]..[Nashville Housing]

select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from [Ekoyo's Portfolio Projects]..[Nashville Housing]

alter table [Nashville Housing]
add OwnerSplitAddress nvarchar(255);
update [Nashville Housing]
set OwnerSplitAddress= PARSENAME(replace(OwnerAddress,',','.'),3)

alter table [Nashville Housing]
add OwnerSplitCity nvarchar(255);
update [Nashville Housing]
set OwnerSplitCity= PARSENAME(replace(OwnerAddress,',','.'),2)

alter table [Nashville Housing]
add OwnerSplitState nvarchar(255);
update [Nashville Housing]
set OwnerSplitState= PARSENAME(replace(OwnerAddress,',','.'),1)

--change 0 and 1 to yes and no in "SoldAsVacant" column
alter table [Ekoyo's Portfolio Projects]..[Nashville Housing]
alter column soldasvacant varchar(50)

select distinct(SoldAsVacant), count (soldasvacant),
case when SoldAsVacant = '0' then 'No'
when SoldAsVacant = '1' then 'Yes'
else SoldAsVacant
end
from [Ekoyo's Portfolio Projects]..[Nashville Housing]
group by SoldAsVacant

update [Ekoyo's Portfolio Projects]..[Nashville Housing]
set SoldAsVacant=
case when SoldAsVacant = '0' then 'No'
when SoldAsVacant = '1' then 'Yes'
else SoldAsVacant
end

--Removing Duplicates
with Row_numCTE as(
select *,
ROW_NUMBER () over(
partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by
			   uniqueID) 
			   Row_num
from [Ekoyo's Portfolio Projects]..[Nashville Housing]
--order by ParcelID
)
select*
--delete 
from Row_numCTE
where Row_num>1
--order by PropertyAddress

--Deleting Unused Columns
alter table [Ekoyo's Portfolio Projects]..[Nashville Housing]
drop column taxdistrict

select *
from [Ekoyo's Portfolio Projects]..[Nashville Housing]
